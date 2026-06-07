import WidgetKit
import SwiftUI

/// 홈/잠금화면에서 "오늘 기록했나?"를 한눈에 보여주는 스트릭 위젯.
struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LogProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("연속 기록")
        .description("스트릭과 이번 주 기록 현황을 보여줘요.")
        .supportedFamilies([
            .systemSmall, .systemMedium,
            .accessoryCircular, .accessoryRectangular, .accessoryInline
        ])
    }
}

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: LogSnapshot

    var body: some View {
        switch family {
        case .accessoryInline:
            Label(inlineText, systemImage: "flame.fill")
        case .accessoryCircular:
            circular
        case .accessoryRectangular:
            rectangular
        case .systemMedium:
            medium
        default:
            small
        }
    }

    // 잠금화면 원형
    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "flame.fill").font(.caption)
                Text("\(entry.streak)").font(.title3.bold())
            }
        }
        .widgetURL(DeepLink.quickAddChooser)
    }

    // 잠금화면 가로형
    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("\(entry.streak)일 연속", systemImage: "flame.fill")
                .font(.headline)
            Text(entry.didLogToday ? "오늘 완료 ✓" : "오늘 기록하기")
                .font(.caption)
                .foregroundStyle(.secondary)
            WeekDotsRow(dots: entry.weekDots, size: 8)
        }
        .widgetURL(DeepLink.quickAddChooser)
    }

    // 홈 작은 위젯
    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill").foregroundStyle(.orange)
                Spacer()
                if entry.didLogToday {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
            }
            Spacer()
            Text("\(entry.streak)일")
                .font(.system(size: 34, weight: .bold))
            Text(entry.didLogToday ? "오늘 완료!" : "오늘도 한 줄")
                .font(.caption)
                .foregroundStyle(.secondary)
            WeekDotsRow(dots: entry.weekDots, size: 9)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(DeepLink.quickAddChooser)
    }

    // 홈 중간 위젯
    private var medium: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill").foregroundStyle(.orange)
                    Text("\(entry.streak)일 연속")
                        .font(.title3.bold())
                }
                Text(entry.didLogToday ? "오늘 기록 완료 ✓" : "오늘 기록을 남겨요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                WeekDotsRow(dots: entry.weekDots, size: 11, showLabels: true)
            }
            Spacer()
            // 빠른 입력 바로가기
            Link(destination: DeepLink.quickAddChooser) {
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill").font(.title)
                    Text("기록").font(.caption)
                }
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var inlineText: String {
        entry.didLogToday ? "\(entry.streak)일 · 오늘 완료" : "\(entry.streak)일 · 오늘 기록하기"
    }
}

/// 한 주의 기록 점 표시.
struct WeekDotsRow: View {
    let dots: [StreakCalculator.DayDot]
    var size: CGFloat = 10
    var showLabels: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(dots) { dot in
                VStack(spacing: 2) {
                    Circle()
                        .fill(color(for: dot))
                        .frame(width: size, height: size)
                    if showLabels {
                        Text(dot.label).font(.system(size: 8)).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func color(for dot: StreakCalculator.DayDot) -> Color {
        if dot.isLogged { return .orange }
        if dot.isFuture { return .gray.opacity(0.25) }
        return .gray.opacity(0.45)
    }
}

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    LogSnapshot.placeholder
}
