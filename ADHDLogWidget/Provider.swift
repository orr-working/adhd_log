import WidgetKit
import SwiftData
import Foundation

/// 위젯에 표시할 스냅샷.
struct LogSnapshot: TimelineEntry {
    let date: Date
    let streak: Int
    let didLogToday: Bool
    let weekDots: [StreakCalculator.DayDot]

    static let placeholder = LogSnapshot(
        date: Date(),
        streak: 3,
        didLogToday: false,
        weekDots: StreakCalculator.weekDots([])
    )
}

/// App Group 공유 저장소에서 직접 읽어 스트릭을 계산하는 프로바이더.
struct LogProvider: TimelineProvider {

    func placeholder(in context: Context) -> LogSnapshot { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (LogSnapshot) -> Void) {
        completion(makeSnapshot())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LogSnapshot>) -> Void) {
        let snapshot = makeSnapshot()
        // 다음 자정 직후에 갱신 (날짜가 바뀌면 스트릭/오늘여부도 갱신되어야 함).
        let nextMidnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 1),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [snapshot], policy: .after(nextMidnight)))
    }

    /// 위젯 스레드에서 안전하게 쓰도록 컨테이너로부터 새 ModelContext 를 만들어 읽는다.
    private func fetchEntries() -> [LogEntry] {
        let context = ModelContext(PersistenceController.shared)
        let descriptor = FetchDescriptor<LogEntry>()
        return (try? context.fetch(descriptor)) ?? []
    }

    private func makeSnapshot() -> LogSnapshot {
        let entries = fetchEntries()
        return LogSnapshot(
            date: Date(),
            streak: StreakCalculator.currentStreak(from: entries),
            didLogToday: StreakCalculator.didLogToday(entries),
            weekDots: StreakCalculator.weekDots(entries)
        )
    }
}
