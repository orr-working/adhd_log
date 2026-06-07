import Foundation

/// 채팅 입력 텍스트에서 카테고리·별점 등을 "추측"한다.
/// ADHD 사용성: 사용자가 칸을 고를 필요 없이, 그냥 쓴 걸 앱이 알아서 분류 제안.
/// 추측이 틀려도 칩을 탭해 바로 바꿀 수 있으므로 가볍게 동작한다.
enum EntryParser {

    struct Result {
        var category: LogCategory
        var rating: Int          // 0 = 없음
        var cleanedText: String  // 별점 표기 등을 걷어낸 본문
    }

    /// 카테고리별 키워드. 더 구체적인(드문) 카테고리를 먼저 검사한다.
    private static let keywords: [(LogCategory, [String])] = [
        (.musical,     ["뮤지컬", "musical"]),
        (.performance, ["공연", "콘서트", "연극", "내한", "페스티벌", "concert"]),
        (.movie,       ["영화", "극장", "시사회", "넷플", "넷플릭스", "movie", "ott"]),
        (.book,        ["책", "독서", "읽었", "읽는", "읽고", "소설", "책읽", "page", "페이지"]),
        (.music,       ["노래", "음악", "앨범", "플레이리스트", "들었", "듣는", "song", "music"]),
        (.photo,       ["사진", "찍었", "photo"]),
        (.diary,       []),
    ]

    /// 추측 실행. forcedCategory 가 있으면 카테고리는 그대로 두고 별점만 파싱.
    static func parse(_ raw: String, forcedCategory: LogCategory? = nil, hasPhoto: Bool = false) -> Result {
        let rating = parseRating(raw)
        let cleaned = stripRating(from: raw)

        if let forced = forcedCategory {
            return Result(category: forced, rating: rating, cleanedText: cleaned)
        }

        let category = guessCategory(raw, hasPhoto: hasPhoto)
        return Result(category: category, rating: rating, cleanedText: cleaned)
    }

    /// 텍스트만으로 카테고리 추측 (입력 중 실시간 미리보기에도 사용).
    static func guessCategory(_ raw: String, hasPhoto: Bool = false) -> LogCategory {
        let text = raw.lowercased()
        for (category, words) in keywords where !words.isEmpty {
            if words.contains(where: { text.contains($0.lowercased()) }) {
                return category
            }
        }
        if hasPhoto { return .photo }
        return .diary
    }

    // MARK: - 별점 파싱

    /// ⭐/★ 개수, "5/5", "4점", "별 3" 등을 인식.
    static func parseRating(_ raw: String) -> Int {
        let stars = raw.filter { $0 == "⭐" || $0 == "★" }.count
        if stars > 0 { return min(stars, 5) }

        if let n = firstCapturedDigit(in: raw, pattern: #"(\d)\s*/\s*5"#) { return clamp(n) }
        if let n = firstCapturedDigit(in: raw, pattern: #"별\s*(\d)"#) { return clamp(n) }
        if let n = firstCapturedDigit(in: raw, pattern: #"(\d)\s*점"#) { return clamp(n) }
        return 0
    }

    private static func stripRating(from raw: String) -> String {
        var s = raw
        for ch in ["⭐", "★", "☆"] { s = s.replacingOccurrences(of: ch, with: "") }
        s = s.replacingOccurrences(of: #"\d\s*/\s*5"#, with: "", options: .regularExpression)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func firstCapturedDigit(in text: String, pattern: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: text),
              let value = Int(text[range]) else { return nil }
        return value
    }

    private static func clamp(_ n: Int) -> Int { max(0, min(n, 5)) }
}
