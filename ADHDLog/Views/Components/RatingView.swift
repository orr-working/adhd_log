import SwiftUI

/// 별점 표시/입력. interactive=true 면 탭으로 점수 변경.
struct RatingView: View {
    @Binding var rating: Int
    var size: CGFloat = 28
    var interactive: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(i <= rating ? Color.yellow : Color(.tertiaryLabel))
                    .onTapGesture {
                        guard interactive else { return }
                        // 같은 별 다시 누르면 해제
                        rating = (rating == i) ? i - 1 : i
                    }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("별점")
        .accessibilityValue("\(rating)점")
    }
}
