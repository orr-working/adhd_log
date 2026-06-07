import SwiftUI

/// 기분 선택. 이모지 하나만 탭하면 되도록 — 글쓰기 부담이 큰 날의 최소 기록 수단.
struct MoodPicker: View {
    @Binding var mood: Mood?

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Mood.allCases) { m in
                let isOn = mood == m
                Button {
                    mood = isOn ? nil : m
                } label: {
                    VStack(spacing: 4) {
                        Text(m.emoji)
                            .font(.system(size: 26))
                        Text(m.label)
                            .font(.caption2)
                            .foregroundStyle(isOn ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isOn ? m.tint.opacity(0.22) : Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: Theme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.smallCornerRadius, style: .continuous)
                            .strokeBorder(isOn ? m.tint : .clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
