import SwiftUI

/// 빠른 입력: 무엇을 기록할지 큰 버튼 그리드에서 한 번 탭.
struct CategoryChooserSheet: View {
    let onSelect: (LogCategory) -> Void
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color(.tertiaryLabel))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("무엇을 기록할까요?")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(LogCategory.quickAddOrder) { cat in
                    Button {
                        onSelect(cat)
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(cat.tint.opacity(0.18))
                                    .frame(width: 56, height: 56)
                                Image(systemName: cat.symbol)
                                    .font(.title2)
                                    .foregroundStyle(cat.tint)
                            }
                            Text(cat.label)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 0)
        }
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        CategoryChooserSheet { _ in }
            .presentationDetents([.height(360)])
    }
}
