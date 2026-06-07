import Foundation
import SwiftData

/// SwiftData PersistentIdentifier 를 Equatable 박스로 감싸 보관.
struct PersistentIdentifierBox: Equatable {
    let id: PersistentIdentifier
}

/// 방금 보낸 기록에 대해 봇이 가볍게 한 가지만 되묻는다.
/// ADHD 원칙: 한 번에 하나만, 항상 "건너뛰기" 가능. 절대 채근하지 않음.
struct FollowUp: Identifiable, Equatable {
    enum Kind: Equatable {
        case rating          // 별점 매길까요?
        case creator(String) // 감독/저자/아티스트는? (라벨 포함)
        case status          // 봤어요 / 보는중 / 보고싶어요?
    }

    let id = UUID()
    let entryID: PersistentIdentifierBox
    let kind: Kind

    static func == (lhs: FollowUp, rhs: FollowUp) -> Bool { lhs.id == rhs.id }
}

enum FollowUpEngine {
    /// 기록을 보고 가장 도움이 될 되묻기 하나를 고른다. 없으면 nil.
    static func next(for entry: LogEntry) -> FollowUp? {
        let box = PersistentIdentifierBox(id: entry.persistentModelID)

        if entry.category.usesRating && entry.rating == 0 {
            return FollowUp(entryID: box, kind: .rating)
        }
        if entry.category.usesStatus && entry.status == nil {
            return FollowUp(entryID: box, kind: .status)
        }
        if let label = entry.category.secondaryFieldLabel, entry.creator.isEmpty {
            return FollowUp(entryID: box, kind: .creator(label))
        }
        return nil
    }

    /// 봇 말풍선에 보일 질문 문구.
    static func prompt(for kind: FollowUp.Kind) -> String {
        switch kind {
        case .rating:          return "별점 매길까요?"
        case .status:          return "지금 상태는 어때요?"
        case .creator(let l):  return "\(l) 추가할래요? (선택)"
        }
    }
}
