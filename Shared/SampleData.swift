import Foundation
import SwiftData

/// 미리보기 / 첫 실행 데모용 샘플 데이터.
enum SampleData {
    @MainActor
    static func insert(into context: ModelContext) {
        let cal = Calendar.current
        func day(_ ago: Int) -> Date {
            cal.date(byAdding: .day, value: -ago, to: Date()) ?? Date()
        }

        let samples: [LogEntry] = [
            LogEntry(category: .diary, entryDate: day(0),
                     note: "아침에 산책했다. 햇빛이 좋았음.", mood: .good),
            LogEntry(category: .book, entryDate: day(0),
                     title: "아주 작은 습관의 힘", rating: 5,
                     status: .done, creator: "제임스 클리어"),
            LogEntry(category: .movie, entryDate: day(1),
                     title: "인사이드 아웃 2", rating: 4,
                     status: .done, creator: "켈시 만"),
            LogEntry(category: .music, entryDate: day(2),
                     title: "좋아하는 플레이리스트 종일 들음", creator: "여러 아티스트"),
            LogEntry(category: .musical, entryDate: day(3),
                     title: "위키드", rating: 5, status: .done,
                     creator: "블루스퀘어"),
            LogEntry(category: .diary, entryDate: day(4),
                     note: "조금 힘든 하루. 그래도 기록은 남김.", mood: .down),
        ]

        for entry in samples {
            context.insert(entry)
        }
        try? context.save()
    }
}
