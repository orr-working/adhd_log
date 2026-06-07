import Foundation

/// 연속 기록(스트릭)과 주간 현황을 계산한다.
/// ADHD 동기부여의 핵심 — 단, "끊겨도 죄책감 주지 않는" 톤으로 표시한다(뷰에서 처리).
enum StreakCalculator {

    /// 기록이 있는 날짜들(중복 제거, 자정 기준)을 정렬해 반환.
    static func loggedDays(from entries: [LogEntry], calendar: Calendar = .current) -> Set<Date> {
        Set(entries.map { calendar.startOfDay(for: $0.entryDate) })
    }

    /// 오늘 기준 현재 연속 일수.
    /// 오늘 기록이 없어도 어제까지 이어졌다면 스트릭은 유지로 본다(오늘은 아직 진행 중).
    static func currentStreak(from entries: [LogEntry],
                              today: Date = Date(),
                              calendar: Calendar = .current) -> Int {
        let days = loggedDays(from: entries, calendar: calendar)
        guard !days.isEmpty else { return 0 }

        let start = calendar.startOfDay(for: today)
        var cursor = start
        var streak = 0

        // 오늘 기록이 없으면 어제부터 카운트 시작 (오늘은 아직 기회가 남음).
        if !days.contains(start) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: start) else { return 0 }
            cursor = yesterday
        }

        while days.contains(cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    /// 역대 최장 연속 일수.
    static func longestStreak(from entries: [LogEntry], calendar: Calendar = .current) -> Int {
        let days = loggedDays(from: entries, calendar: calendar).sorted()
        guard !days.isEmpty else { return 0 }

        var best = 1
        var run = 1
        for i in 1..<days.count {
            if let prev = calendar.date(byAdding: .day, value: 1, to: days[i - 1]),
               prev == days[i] {
                run += 1
                best = max(best, run)
            } else {
                run = 1
            }
        }
        return best
    }

    /// 오늘 기록했는지 여부.
    static func didLogToday(_ entries: [LogEntry],
                            today: Date = Date(),
                            calendar: Calendar = .current) -> Bool {
        let start = calendar.startOfDay(for: today)
        return loggedDays(from: entries, calendar: calendar).contains(start)
    }

    /// 이번 주(월~일) 각 요일의 기록 여부. 위젯의 점 표시용.
    static func weekDots(_ entries: [LogEntry],
                         today: Date = Date(),
                         calendar: Calendar = .current) -> [DayDot] {
        var cal = calendar
        cal.firstWeekday = 2 // 월요일 시작
        let days = loggedDays(from: entries, calendar: cal)

        let start = cal.startOfDay(for: today)
        let weekday = cal.component(.weekday, from: start) // 1=일 … 7=토
        let offsetToMonday = (weekday + 5) % 7
        guard let monday = cal.date(byAdding: .day, value: -offsetToMonday, to: start) else { return [] }

        let symbols = ["월", "화", "수", "목", "금", "토", "일"]
        return (0..<7).compactMap { i in
            guard let date = cal.date(byAdding: .day, value: i, to: monday) else { return nil }
            return DayDot(
                label: symbols[i],
                date: date,
                isLogged: days.contains(date),
                isToday: cal.isDate(date, inSameDayAs: start),
                isFuture: date > start
            )
        }
    }

    struct DayDot: Identifiable {
        let id = UUID()
        let label: String
        let date: Date
        let isLogged: Bool
        let isToday: Bool
        let isFuture: Bool
    }
}
