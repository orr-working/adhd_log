import Foundation

/// 채팅 스트림 한 줄. 오래된 것이 위, 최신이 아래(메신저와 동일).
enum ChatItem: Identifiable {
    case monthSummary(MonthSummary)
    case daySeparator(Date)
    case entry(LogEntry)

    var id: String {
        switch self {
        case .monthSummary(let s): return "m-\(s.id)"
        case .daySeparator(let d): return "d-\(d.timeIntervalSince1970)"
        case .entry(let e):        return "e-\(e.uuid)"
        }
    }
}

enum ChatComposer {
    /// 기록들을 오래된→최신 순으로 정렬하고, 월 요약 카드와 날짜 구분선을 끼워 넣는다.
    static func build(from entries: [LogEntry], calendar: Calendar = .current) -> [ChatItem] {
        let sorted = entries.sorted {
            if $0.entryDate != $1.entryDate { return $0.entryDate < $1.entryDate }
            return $0.createdAt < $1.createdAt
        }

        var items: [ChatItem] = []
        var lastDay: Date?
        var lastMonth: Date?

        // 월별 그룹(요약용)
        let byMonth = Dictionary(grouping: sorted) { entry -> Date in
            let comps = calendar.dateComponents([.year, .month], from: entry.entryDate)
            return calendar.date(from: comps) ?? entry.entryDate
        }

        for entry in sorted {
            let day = calendar.startOfDay(for: entry.entryDate)
            let monthComps = calendar.dateComponents([.year, .month], from: entry.entryDate)
            let month = calendar.date(from: monthComps) ?? day

            if lastMonth != month {
                let monthEntries = byMonth[month] ?? []
                items.append(.monthSummary(SummaryBuilder.make(monthStart: month, entries: monthEntries)))
                lastMonth = month
                lastDay = nil // 새 달이면 날짜 구분선도 다시
            }
            if lastDay != day {
                items.append(.daySeparator(day))
                lastDay = day
            }
            items.append(.entry(entry))
        }
        return items
    }
}
