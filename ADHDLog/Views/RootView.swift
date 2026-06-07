import SwiftUI
import SwiftData

/// 화면 이동 경로.
enum Route: Hashable {
    case search
    case stats
    case settings
}

/// 앱 최상위. 채팅 화면 + 상단바(작성/메뉴) + 푸시 네비게이션.
struct RootView: View {
    @Binding var quickAddRequest: QuickAddRequest?

    @State private var path = NavigationPath()
    @State private var showingChooser = false
    @State private var editingEntry: LogEntry?

    var body: some View {
        NavigationStack(path: $path) {
            ChatView(incoming: $quickAddRequest)
                .navigationTitle("기록")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.tap()
                            showingChooser = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .accessibilityLabel("자세히 기록")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button { path.append(Route.search) } label: {
                                Label("검색", systemImage: "magnifyingglass")
                            }
                            Button { path.append(Route.stats) } label: {
                                Label("통계", systemImage: "chart.bar")
                            }
                            Button { path.append(Route.settings) } label: {
                                Label("설정", systemImage: "gearshape")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .accessibilityLabel("메뉴")
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .search:   SearchView()
                    case .stats:    StatsView()
                    case .settings: SettingsView()
                    }
                }
        }
        .tint(.accentColor)
        .task { rescheduleReminderFromDefaults() }
        // 자세히 기록: 카테고리 선택 → 전체 입력 폼
        .sheet(isPresented: $showingChooser) {
            CategoryChooserSheet { category in
                showingChooser = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    editingEntry = LogEntry(category: category)
                }
            }
            .presentationDetents([.height(360), .medium])
        }
        .sheet(item: $editingEntry) { entry in
            EntryEditView(entry: entry, isNew: true)
        }
    }

    /// 저장된 설정대로 매일 리마인더를 다시 예약 (앱 실행 시).
    private func rescheduleReminderFromDefaults() {
        let d = UserDefaults.standard
        guard d.bool(forKey: "reminderEnabled") else { return }
        NotificationManager.reschedule(
            enabled: true,
            hour: d.integer(forKey: "reminderHour"),
            minute: d.integer(forKey: "reminderMinute")
        )
    }
}

#Preview {
    RootView(quickAddRequest: .constant(nil))
        .modelContainer(PersistenceController.preview)
}
