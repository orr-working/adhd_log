import Foundation
import SwiftData

/// 모든 기록의 단일 모델. 일기·사진·책·영화·뮤지컬·음악·공연을 하나의 타임라인으로 묶는다.
///
/// ADHD 사용성을 위해 "여러 앱/탭을 오가지 않고 한 흐름에서 다 보이게" 하나의 모델로 설계.
///
/// CloudKit 동기화 호환을 위해:
///  - 모든 속성에 기본값이 있어야 하고
///  - 고유 제약(unique)을 쓰지 않으며
///  - 관계는 옵셔널이어야 한다.
@Model
final class LogEntry {
    /// 동기화 충돌 방지를 위한 식별자 (unique 제약 대신 일반 속성으로 둔다).
    var uuid: String = UUID().uuidString

    /// 기록을 만든 시각
    var createdAt: Date = Date()

    /// 이 기록이 "속하는" 날짜 (타임라인/스트릭 계산 기준)
    var entryDate: Date = Date()

    /// 카테고리 (rawValue로 저장)
    var categoryRaw: String = LogCategory.diary.rawValue

    /// 제목 / 한 줄 (일기는 제목 생략 가능)
    var title: String = ""

    /// 본문 / 메모 / 감상
    var note: String = ""

    /// 별점 0~5 (0 = 없음)
    var rating: Int = 0

    /// 기분 (옵셔널)
    var moodRaw: String?

    /// 진행 상태 (미디어용, 옵셔널)
    var statusRaw: String?

    /// 저자/감독/아티스트/장소 등 보조 정보
    var creator: String = ""

    /// 첨부 사진 (대용량이므로 외부 저장)
    @Attribute(.externalStorage) var photoData: Data?

    init(
        category: LogCategory = .diary,
        entryDate: Date = Date(),
        title: String = "",
        note: String = "",
        rating: Int = 0,
        mood: Mood? = nil,
        status: LogStatus? = nil,
        creator: String = "",
        photoData: Data? = nil
    ) {
        self.uuid = UUID().uuidString
        self.createdAt = Date()
        self.entryDate = entryDate
        self.categoryRaw = category.rawValue
        self.title = title
        self.note = note
        self.rating = rating
        self.moodRaw = mood?.rawValue
        self.statusRaw = status?.rawValue
        self.creator = creator
        self.photoData = photoData
    }
}

// MARK: - 편의 접근자 (rawValue ↔ enum 변환)

extension LogEntry {
    var category: LogCategory {
        get { LogCategory(rawValue: categoryRaw) ?? .diary }
        set { categoryRaw = newValue.rawValue }
    }

    var mood: Mood? {
        get { moodRaw.flatMap(Mood.init(rawValue:)) }
        set { moodRaw = newValue?.rawValue }
    }

    var status: LogStatus? {
        get { statusRaw.flatMap(LogStatus.init(rawValue:)) }
        set { statusRaw = newValue?.rawValue }
    }

    /// 타임라인 행에 보여줄 대표 텍스트.
    var displayTitle: String {
        if !title.isEmpty { return title }
        if !note.isEmpty { return note }
        return category.label
    }
}
