import SwiftUI
import SwiftData

@main
struct ADHDLogApp: App {
    /// 위젯 딥링크로 들어온 빠른 입력 요청. RootView 가 관찰해 시트를 띄운다.
    @State private var quickAddRequest: QuickAddRequest?

    init() {
        // 리마인더 기본 시간값 등록 (저녁 9시).
        UserDefaults.standard.register(defaults: [
            "reminderHour": 21,
            "reminderMinute": 0
        ])
    }

    var body: some Scene {
        WindowGroup {
            RootView(quickAddRequest: $quickAddRequest)
                .onOpenURL { url in
                    if let request = DeepLink.parse(url) {
                        quickAddRequest = request
                    }
                }
        }
        .modelContainer(PersistenceController.shared)
    }
}
