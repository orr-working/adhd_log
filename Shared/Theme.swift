import SwiftUI

/// 앱/위젯 공용 디자인 토큰. 부드럽고 산만하지 않은 톤으로 통일한다.
enum Theme {
    /// 큰 둥근 모서리 (ADHD 친화적인 부드러운 카드 느낌)
    static let cornerRadius: CGFloat = 18
    static let smallCornerRadius: CGFloat = 12

    /// 표준 간격
    static let spacing: CGFloat = 16

    /// 배경 그라데이션 (은은하게)
    static func background(for scheme: ColorScheme) -> LinearGradient {
        let colors: [Color] = scheme == .dark
            ? [Color(white: 0.07), Color(white: 0.04)]
            : [Color(red: 0.97, green: 0.97, blue: 1.0), Color(red: 0.93, green: 0.95, blue: 0.99)]
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    /// 스트릭 강조색
    static let streak = Color.orange
}

// MARK: - URL 스킴 (위젯 → 앱 딥링크)

enum DeepLink {
    static let scheme = "adhdlog"

    /// 특정 카테고리로 빠른 입력 화면 열기: adhdlog://add?category=diary
    static func quickAdd(_ category: LogCategory) -> URL {
        URL(string: "\(scheme)://add?category=\(category.rawValue)")!
    }

    /// 빠른 입력 선택 화면 열기: adhdlog://add
    static var quickAddChooser: URL {
        URL(string: "\(scheme)://add")!
    }

    /// 파싱: 들어온 URL 이 빠른 입력 요청이면 (카테고리 옵셔널) 반환.
    static func parse(_ url: URL) -> QuickAddRequest? {
        guard url.scheme == scheme, url.host == "add" else { return nil }
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let raw = comps?.queryItems?.first(where: { $0.name == "category" })?.value
        let category = raw.flatMap(LogCategory.init(rawValue:))
        return QuickAddRequest(category: category)
    }
}

struct QuickAddRequest: Equatable {
    var category: LogCategory?
}
