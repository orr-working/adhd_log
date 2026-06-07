import SwiftUI
import SwiftData

/// 앱 최상위. 채팅 화면을 보여주고, 위젯 딥링크/상세 입력 진입을 관리한다.
struct RootView: View {
    @Binding var quickAddRequest: QuickAddRequest?

    /// 상세 입력(사진·모든 칸) 진입용 시트
    @State private var showingChooser = false
    @State private var editingEntry: LogEntry?

    var body: some View {
        NavigationStack {
            ChatView(incoming: $quickAddRequest)
                .navigationTitle("기록")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingChooser = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .accessibilityLabel("자세히 기록")
                    }
                }
        }
        .tint(.accentColor)
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
}

#Preview {
    RootView(quickAddRequest: .constant(nil))
        .modelContainer(PersistenceController.preview)
}
