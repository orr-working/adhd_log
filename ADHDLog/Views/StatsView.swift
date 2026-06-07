import SwiftUI
import SwiftData
import Charts

/// 통계 / 회고 화면. 그동안 쌓인 기록을 시각적 보상으로 돌려준다.
struct StatsView: View {
    @Environment(\.colorScheme) private var scheme
    @Query private var entries: [LogEntry]

    private var currentStreak: Int { StreakCalculator.currentStreak(from: entries) }
    private var longestStreak: Int { StreakCalculator.longestStreak(from: entries) }

    private var thisMonth: MonthSummary {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        let monthStart = cal.date(from: comps) ?? Date()
        let monthEntries = entries.filter {
            cal.dateComponents([.year, .month], from: $0.entryDate) == comps
        }
        return SummaryBuilder.make(monthStart: monthStart, entries: monthEntries)
    }

    private var categoryCounts: [CatCount] {
        LogCategory.allCases
            .map { cat in CatCount(category: cat, count: entries.filter { $0.category == cat }.count) }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    private var moodCounts: [MoodCount] {
        Mood.allCases
            .map { m in MoodCount(mood: m, count: entries.filter { $0.mood == m }.count) }
            .filter { $0.count > 0 }
    }

    var body: some View {
        ZStack {
            Theme.background(for: scheme).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    streakCard
                    monthCard
                    recentDaysCard
                    if !categoryCounts.isEmpty { categoryCard }
                    if !moodCounts.isEmpty { moodCard }
                }
                .padding()
            }
        }
        .navigationTitle("통계")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 스트릭

    private var streakCard: some View {
        HStack(spacing: 12) {
            stat(value: "\(currentStreak)", label: "현재 연속", symbol: "flame.fill", tint: .orange)
            stat(value: "\(longestStreak)", label: "최장 연속", symbol: "trophy.fill", tint: .yellow)
            stat(value: "\(entries.count)", label: "전체 기록", symbol: "tray.full.fill", tint: .blue)
        }
    }

    private func stat(value: String, label: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(value).font(.title2.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 이번 달

    private var monthCard: some View {
        card(title: thisMonth.title, symbol: "calendar") {
            if thisMonth.total == 0 {
                Text("이번 달은 아직이에요. 한 줄부터 가볍게 🙂")
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                Text("총 \(thisMonth.total)개")
                    .font(.title3.bold())
                WrapText(lines: SummaryBuilder.lines(thisMonth))
                if let h = thisMonth.highlight {
                    Label("최고: \(h)", systemImage: "star.fill")
                        .font(.caption).foregroundStyle(.orange)
                }
            }
        }
    }

    // MARK: - 최근 14일 (회고용 점/이모지)

    private var recentDaysCard: some View {
        let days = recentDays(14)
        return card(title: "최근 2주", symbol: "square.grid.3x3.fill") {
            HStack(spacing: 4) {
                ForEach(days) { d in
                    VStack(spacing: 3) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(d.logged ? Theme.streak.opacity(0.85) : Color(.systemFill))
                                .frame(height: 26)
                            if let emoji = d.moodEmoji { Text(emoji).font(.caption2) }
                        }
                        Text(d.dayNumber).font(.system(size: 8)).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - 카테고리 분포

    private var categoryCard: some View {
        card(title: "카테고리", symbol: "chart.bar.fill") {
            Chart(categoryCounts) { item in
                BarMark(
                    x: .value("개수", item.count),
                    y: .value("카테고리", item.category.label)
                )
                .foregroundStyle(item.category.tint)
                .annotation(position: .trailing) {
                    Text("\(item.count)").font(.caption2).foregroundStyle(.secondary)
                }
            }
            .chartXAxis(.hidden)
            .frame(height: CGFloat(categoryCounts.count) * 34 + 10)
        }
    }

    // MARK: - 기분 분포

    private var moodCard: some View {
        card(title: "기분", symbol: "face.smiling") {
            Chart(moodCounts) { item in
                BarMark(
                    x: .value("개수", item.count),
                    y: .value("기분", item.mood.emoji)
                )
                .foregroundStyle(item.mood.tint)
                .annotation(position: .trailing) {
                    Text("\(item.count)").font(.caption2).foregroundStyle(.secondary)
                }
            }
            .chartXAxis(.hidden)
            .frame(height: CGFloat(moodCounts.count) * 34 + 10)
        }
    }

    // MARK: - 공용 카드

    private func card<Content: View>(title: String, symbol: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 최근 N일 계산

    private func recentDays(_ count: Int) -> [DayCell] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // 날짜별 대표 기분 (마지막 기록 기준)
        var moodByDay: [Date: Mood] = [:]
        var loggedDays = Set<Date>()
        for e in entries {
            let day = cal.startOfDay(for: e.entryDate)
            loggedDays.insert(day)
            if let m = e.mood { moodByDay[day] = m }
        }
        return (0..<count).reversed().compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DayCell(
                date: date,
                dayNumber: "\(cal.component(.day, from: date))",
                logged: loggedDays.contains(date),
                moodEmoji: moodByDay[date]?.emoji
            )
        }
    }
}

// MARK: - 모델

private struct CatCount: Identifiable {
    let category: LogCategory
    let count: Int
    var id: String { category.rawValue }
}

private struct MoodCount: Identifiable {
    let mood: Mood
    let count: Int
    var id: String { mood.rawValue }
}

private struct DayCell: Identifiable {
    let date: Date
    let dayNumber: String
    let logged: Bool
    let moodEmoji: String?
    var id: Date { date }
}

/// 칩 형태로 줄바꿈 표시.
private struct WrapText: View {
    let lines: [String]
    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 80), spacing: 6)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
            ForEach(lines, id: \.self) { t in
                Text(t)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color(.secondarySystemBackground), in: Capsule())
            }
        }
    }
}

#Preview {
    NavigationStack { StatsView() }
        .modelContainer(PersistenceController.preview)
}
