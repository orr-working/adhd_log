#!/usr/bin/env bash
# CI에서 본인 계정에 맞는 번들 ID/App Group/iCloud 컨테이너/팀 ID를
# 코드에 주입한다. (저장소 코드는 그대로 두고, 빌드 시점에만 치환)
#
# 필요한 환경변수:
#   BUNDLE_ID        예: com.nahyeon.adhdlog   (본인 소유의 reverse-domain)
#   APPLE_TEAM_ID    예: ABCDE12345            (애플 개발자 팀 ID, 10자리)
#
# 파생값:
#   위젯 번들      = $BUNDLE_ID.widget
#   App Group     = group.$BUNDLE_ID
#   iCloud 컨테이너 = iCloud.$BUNDLE_ID
set -euo pipefail

: "${BUNDLE_ID:?BUNDLE_ID 가 필요합니다 (예: com.nahyeon.adhdlog)}"
: "${APPLE_TEAM_ID:?APPLE_TEAM_ID 가 필요합니다 (애플 개발자 팀 ID)}"

APP_BUNDLE="$BUNDLE_ID"
WIDGET_BUNDLE="$BUNDLE_ID.widget"
APP_GROUP="group.$BUNDLE_ID"
ICLOUD="iCloud.$BUNDLE_ID"

echo "▶︎ App     : $APP_BUNDLE"
echo "▶︎ Widget  : $WIDGET_BUNDLE"
echo "▶︎ Group   : $APP_GROUP"
echo "▶︎ iCloud  : $ICLOUD"
echo "▶︎ Team    : $APPLE_TEAM_ID"

# 현재 코드에 박혀 있는 기본값들 (이 값을 본인 값으로 치환).
OLD_APP="com.adhdlog.app"
OLD_WIDGET="com.adhdlog.app.widget"
OLD_GROUP="group.com.adhdlog.shared"
OLD_ICLOUD="iCloud.com.adhdlog.app"

# macOS(BSD) sed 와 GNU sed 모두 동작하도록 -i '' 대신 임시파일 방식 사용.
replace() { # replace <find> <repl> <file>
  local find="$1" repl="$2" file="$3"
  python3 - "$find" "$repl" "$file" <<'PY'
import sys, io
find, repl, path = sys.argv[1], sys.argv[2], sys.argv[3]
with io.open(path, "r", encoding="utf-8") as f:
    data = f.read()
data = data.replace(find, repl)
with io.open(path, "w", encoding="utf-8") as f:
    f.write(data)
PY
}

# 1) project.yml — 번들 ID + 팀 ID
#    (widget 을 먼저 치환해야 app 치환이 widget 까지 망치지 않음)
replace "$OLD_WIDGET" "$WIDGET_BUNDLE" project.yml
replace "$OLD_APP" "$APP_BUNDLE" project.yml
replace 'DEVELOPMENT_TEAM: ""' "DEVELOPMENT_TEAM: \"$APPLE_TEAM_ID\"" project.yml

# 2) 엔타이틀먼트 (앱 / 위젯) — App Group + iCloud
for ent in ADHDLog/ADHDLog.entitlements ADHDLogWidget/ADHDLogWidget.entitlements; do
  replace "$OLD_GROUP" "$APP_GROUP" "$ent"
  replace "$OLD_ICLOUD" "$ICLOUD" "$ent"
done

# 3) 공유 저장소가 보는 App Group 식별자
replace "$OLD_GROUP" "$APP_GROUP" Shared/PersistenceController.swift

echo "✅ 서명/식별자 주입 완료"
