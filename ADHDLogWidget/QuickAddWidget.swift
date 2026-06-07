import WidgetKit
import SwiftUI

/// 홈 화면에서 카테고리를 바로 탭해 기록을 시작하는 빠른 입력 위젯.
/// ADHD 핵심: "앱을 찾아 들어가는 단계"를 없앤다 — 위젯에서 곧장 입력.
struct QuickAddWidget: Widget {
    let kind = "QuickAddWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LogProvider()) { _ in
            QuickAddWidgetView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("빠른 기록")
        .description("탭 한 번으로 일기·사진·책·영화 등을 바로 기록해요.")
        .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}

struct QuickAddWidgetView: View {
    @Environment(\.widgetFamily) private var family

    /// 위젯에 노출할 대표 카테고리(공간 제한으로 일부만).
    private let homeCategories: [LogCategory] = [.diary, .photo, .book, .movie, .musical, .music]
    private let lockCategories: [LogCategory] = [.diary, .photo, .book, .movie]

    var body: some View {
        switch family {
        case .accessoryRectangular:
            HStack(spacing: 10) {
                ForEach(lockCategories) { cat in
                    Link(destination: DeepLink.quickAdd(cat)) {
                        Image(systemName: cat.symbol)
                            .font(.body)
                    }
                }
            }
        default:
            VStack(spacing: 8) {
                HStack {
                    Text("빠른 기록").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Spacer()
                }
                HStack(spacing: 10) {
                    ForEach(homeCategories) { cat in
                        Link(destination: DeepLink.quickAdd(cat)) {
                            VStack(spacing: 5) {
                                ZStack {
                                    Circle().fill(cat.tint.opacity(0.18))
                                    Image(systemName: cat.symbol)
                                        .font(.system(size: 18))
                                        .foregroundStyle(cat.tint)
                                }
                                .frame(width: 44, height: 44)
                                Text(cat.label).font(.system(size: 10)).foregroundStyle(.primary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview(as: .systemMedium) {
    QuickAddWidget()
} timeline: {
    LogSnapshot.placeholder
}
