import SwiftUI
import UserNotifications

/// 설정: 매일 리마인더 + 앱 정보.
struct SettingsView: View {
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 21
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var permissionDenied = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date()
                ) ?? Date()
            },
            set: { newValue in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = c.hour ?? 21
                reminderMinute = c.minute ?? 0
                apply()
            }
        )
    }

    var body: some View {
        Form {
            Section {
                Toggle("매일 리마인드", isOn: $reminderEnabled)
                    .onChange(of: reminderEnabled) { _, on in
                        if on { enableReminder() } else { apply() }
                    }

                if reminderEnabled {
                    DatePicker("시간", selection: reminderTime, displayedComponents: .hourAndMinute)
                }
            } header: {
                Text("리마인더")
            } footer: {
                if permissionDenied {
                    Text("알림이 꺼져 있어요. 설정 앱 → 기록 → 알림에서 켜주세요.")
                        .foregroundStyle(.orange)
                } else {
                    Text("정한 시간에 부드럽게 한 번 알려드려요. 부담되면 언제든 꺼도 돼요.")
                }
            }

            Section("동기화") {
                Label("iCloud 자동 동기화", systemImage: "icloud")
                Text("같은 Apple ID 기기끼리 자동으로 안전하게 동기화돼요. 데이터는 본인 iCloud에만 저장됩니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("정보") {
                HStack {
                    Text("버전")
                    Spacer()
                    Text(appVersion).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task { await refreshPermissionState() }
    }

    private func enableReminder() {
        Task {
            let granted = await NotificationManager.requestAuthorization()
            await MainActor.run {
                if granted {
                    permissionDenied = false
                    apply()
                } else {
                    permissionDenied = true
                    reminderEnabled = false
                }
            }
        }
    }

    private func apply() {
        NotificationManager.reschedule(
            enabled: reminderEnabled, hour: reminderHour, minute: reminderMinute
        )
    }

    private func refreshPermissionState() async {
        let status = await NotificationManager.authorizationStatus()
        await MainActor.run {
            permissionDenied = (status == .denied) && reminderEnabled
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
