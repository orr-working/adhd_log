import SwiftUI

/// 사용자가 남긴 기록 하나 = 오른쪽 말풍선. 탭하면 상세로.
struct ChatBubbleView: View {
    let entry: LogEntry

    var body: some View {
        HStack {
            Spacer(minLength: 40)
            VStack(alignment: .leading, spacing: 6) {
                // 카테고리 태그 줄
                HStack(spacing: 6) {
                    Image(systemName: entry.category.symbol)
                        .font(.caption2)
                    Text(entry.category.label)
                        .font(.caption2.weight(.semibold))
                    if let mood = entry.mood { Text(mood.emoji).font(.caption2) }
                    if let status = entry.status {
                        Image(systemName: status.symbol).font(.caption2)
                    }
                }
                .foregroundStyle(entry.category.tint)

                if let data = entry.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 220, maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if !entry.displayTitle.isEmpty {
                    Text(entry.displayTitle)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !entry.creator.isEmpty {
                    Text(entry.creator)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if entry.category.usesRating && entry.rating > 0 {
                    RatingView(rating: .constant(entry.rating), size: 13, interactive: false)
                }

                Text(entry.createdAt, format: .dateTime.hour().minute())
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
            .background(
                entry.category.tint.opacity(0.14),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(entry.category.tint.opacity(0.25), lineWidth: 1)
            )
        }
    }
}
