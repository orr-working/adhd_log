import Foundation

/// 월별 자동 요약. 채팅 스트림에 "이번 달 영화 7편" 같은 카드로 떠서 성취감을 준다.
struct MonthSummary: Identifiable, Equatable {
    let id: String          // "2026-06"
    let monthStart: Date
    let total: Int
    let counts: [(category: LogCategory, count: Int)]  // 많은 순
    let highlight: String?  // 이 달 최고 별점 기록 제목 (있으면)

    static func == (lhs: MonthSummary, rhs: MonthSummary) -> Bool {
        lhs.id == rhs.id && lhs.total == rhs.total
    }

    /// "M월" 표시
    var title: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f.string(from: monthStart)
    }
}

enum SummaryBuilder {
    /// 한 달치 기록으로 요약 생성.
    static func make(monthStart: Date, entries: [LogEntry], calendar: Calendar = .current) -> MonthSummary {
        let counts = LogCategory.allCases
            .map { cat in (cat, entries.filter { $0.category == cat }.count) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { (category: $0.0, count: $0.1) }

        let topRated = entries
            .filter { $0.category.usesRating && $0.rating >= 4 && !$0.displayTitle.isEmpty }
            .max(by: { $0.rating < $1.rating })

        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        let id = f.string(from: monthStart)

        return MonthSummary(
            id: id,
            monthStart: monthStart,
            total: entries.count,
            counts: counts,
            highlight: topRated?.displayTitle
        )
    }

    /// 카드 본문 한 줄들: ["영화 7편", "책 3권", ...]
    static func lines(_ s: MonthSummary) -> [String] {
        s.counts.prefix(4).map { "\($0.category.label) \($0.count)\(unit(for: $0.category))" }
    }

    private static func unit(for category: LogCategory) -> String {
        switch category {
        case .book:        return "권"
        case .movie, .musical, .performance: return "편"
        case .music:       return "곡"
        case .photo:       return "장"
        default:           return "개"
        }
    }
}
