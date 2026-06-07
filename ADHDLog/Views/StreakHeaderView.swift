import SwiftUI

/// 타임라인 상단의 스트릭/주간 현황 카드.
/// 끊겨도 비난하지 않고, 채우면 시각적으로 보상되는 톤.
struct StreakHeaderView: View {
    let entries: [LogEntry]

    private var streak: Int { StreakCalculator.currentStreak(from: entries) }
    private var didToday: Bool { StreakCalculator.didLogToday(entries) }
    private var dots: [StreakCalculator.DayDot] { StreakCalculator.weekDots(entries) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(streak > 0 ? Theme.streak.opacity(0.18) : Color(.secondarySystemBackground))
                        .frame(width: 54, height: 54)
                    Image(systemName: streak > 0 ? "flame.fill" : "flame")
                        .font(.title2)
                        .foregroundStyle(streak > 0 ? Theme.streak : .secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(streakTitle)
                        .font(.title3.weight(.bold))
                    Text(streakSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            // 이번 주 점들
            HStack(spacing: 0) {
                ForEach(dots) { dot in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(fill(for: dot))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle().strokeBorder(
                                    dot.isToday ? Color.accentColor : .clear, lineWidth: 2)
                            )
                        Text(dot.label)
                            .font(.caption2)
                            .foregroundStyle(dot.isToday ? Color.accentColor : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(Theme.spacing)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }

    private func fill(for dot: StreakCalculator.DayDot) -> Color {
        if dot.isLogged { return Theme.streak }
        if dot.isFuture { return Color(.tertiarySystemFill) }
        return Color(.systemFill)
    }

    private var streakTitle: String {
        streak > 0 ? "\(streak)일 연속 기록 중" : "오늘부터 시작해요"
    }

    private var streakSubtitle: String {
        if didToday { return "오늘 기록 완료 ✓ 잘하고 있어요" }
        if streak > 0 { return "오늘도 한 줄이면 이어져요" }
        return "한 줄, 사진 한 장도 충분해요"
    }
}

#Preview {
    StreakHeaderView(entries: [])
        .padding()
}
