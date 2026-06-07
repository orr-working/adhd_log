import SwiftUI

/// 기분. 텍스트를 쓰기 부담스러운 날에도 이모지 하나만 탭하면 기록이 남도록 한다.
enum Mood: String, CaseIterable, Identifiable, Codable {
    case great   // 아주 좋음
    case good    // 좋음
    case okay    // 그냥 그럼
    case down    // 가라앉음
    case rough   // 힘듦

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good:  return "🙂"
        case .okay:  return "😐"
        case .down:  return "😔"
        case .rough: return "😩"
        }
    }

    var label: String {
        switch self {
        case .great: return "아주 좋음"
        case .good:  return "좋음"
        case .okay:  return "그냥 그럼"
        case .down:  return "가라앉음"
        case .rough: return "힘듦"
        }
    }

    var tint: Color {
        switch self {
        case .great: return Color(red: 0.30, green: 0.78, blue: 0.50)
        case .good:  return Color(red: 0.55, green: 0.78, blue: 0.40)
        case .okay:  return Color(red: 0.90, green: 0.78, blue: 0.35)
        case .down:  return Color(red: 0.92, green: 0.58, blue: 0.35)
        case .rough: return Color(red: 0.90, green: 0.42, blue: 0.42)
        }
    }
}

/// 미디어 기록의 진행 상태.
enum LogStatus: String, CaseIterable, Identifiable, Codable {
    case wishlist   // 보고/읽고 싶음
    case ongoing    // 보는/읽는 중
    case done       // 완료

    var id: String { rawValue }

    var label: String {
        switch self {
        case .wishlist: return "위시"
        case .ongoing:  return "진행중"
        case .done:     return "완료"
        }
    }

    var symbol: String {
        switch self {
        case .wishlist: return "bookmark"
        case .ongoing:  return "hourglass"
        case .done:     return "checkmark.circle.fill"
        }
    }
}
