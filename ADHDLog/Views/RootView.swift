import SwiftUI
import SwiftData

/// 앱의 최상위 화면. 타임라인을 보여주고, 빠른 입력 시트를 관리한다.
struct RootView: View {
    @Binding var quickAddRequest: QuickAddRequest?
    @Environment(\.colorScheme) private var scheme

    /// 빠른 입력 시트 상태
    @State private var showingChooser = false
    @State private var editingEntry: LogEntry?

    var body: some View {
        NavigationStack {
            TimelineView()
                .navigationTitle("기록")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            startQuickAdd(category: nil)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .accessibilityLabel("새 기록")
                    }
                }
        }
        .tint(.accentColor)
        // 위젯 딥링크 → 빠른 입력
        .onChange(of: quickAddRequest) { _, request in
            guard let request else { return }
            startQuickAdd(category: request.category)
            quickAddRequest = nil
        }
        // 카테고리 선택 시트
        .sheet(isPresented: $showingChooser) {
            CategoryChooserSheet { category in
                showingChooser = false
                // 선택 시트가 닫히는 애니메이션 후 입력 시트로 이어지도록 지연.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    editingEntry = LogEntry(category: category)
                }
            }
            .presentationDetents([.height(360), .medium])
        }
        // 입력/편집 시트
        .sheet(item: $editingEntry) { entry in
            EntryEditView(entry: entry, isNew: true)
        }
    }

    /// 카테고리가 지정되면 곧장 입력 시트, 아니면 선택 시트부터.
    private func startQuickAdd(category: LogCategory?) {
        if let category {
            editingEntry = LogEntry(category: category)
        } else {
            showingChooser = true
        }
    }
}

#Preview {
    RootView(quickAddRequest: .constant(nil))
        .modelContainer(PersistenceController.preview)
}
