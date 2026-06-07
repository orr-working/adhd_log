import SwiftUI

/// 타임라인의 한 줄. 카테고리 색/아이콘으로 한눈에 구분되게.
struct EntryRowView: View {
    let entry: LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 카테고리 아이콘
            ZStack {
                RoundedRectangle(cornerRadius: Theme.smallCornerRadius, style: .continuous)
                    .fill(entry.category.tint.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: entry.category.symbol)
                    .foregroundStyle(entry.category.tint)
                    .font(.system(size: 18, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(entry.category.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(entry.category.tint)
                    if let mood = entry.mood {
                        Text(mood.emoji).font(.caption)
                    }
                    if let status = entry.status {
                        Label(status.label, systemImage: status.symbol)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(entry.createdAt, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text(entry.displayTitle)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if !entry.creator.isEmpty {
                    Text(entry.creator)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if entry.category.usesRating && entry.rating > 0 {
                    RatingView(rating: .constant(entry.rating), size: 12, interactive: false)
                }
            }

            if let data = entry.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius, style: .continuous))
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}
