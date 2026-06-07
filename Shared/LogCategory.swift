import SwiftUI

/// 기록의 종류. ADHD 친화적으로 "한눈에 구분되는 색 + 아이콘"을 갖는다.
enum LogCategory: String, CaseIterable, Identifiable, Codable {
    case diary        // 일기
    case photo        // 사진
    case book         // 책
    case movie        // 영화
    case musical      // 뮤지컬
    case music        // 음악
    case performance  // 공연

    var id: String { rawValue }

    /// 화면에 보이는 한글 이름
    var label: String {
        switch self {
        case .diary:       return "일기"
        case .photo:       return "사진"
        case .book:        return "책"
        case .movie:       return "영화"
        case .musical:     return "뮤지컬"
        case .music:       return "음악"
        case .performance: return "공연"
        }
    }

    /// SF Symbol 아이콘
    var symbol: String {
        switch self {
        case .diary:       return "book.closed.fill"
        case .photo:       return "photo.fill"
        case .book:        return "books.vertical.fill"
        case .movie:       return "film.fill"
        case .musical:     return "theatermasks.fill"
        case .music:       return "music.note"
        case .performance: return "sparkles"
        }
    }

    /// 카테고리별 대표 색 — 시각적 구분이 ADHD 사용성에 중요.
    var tint: Color {
        switch self {
        case .diary:       return Color(red: 0.40, green: 0.55, blue: 0.95) // 파랑
        case .photo:       return Color(red: 0.95, green: 0.62, blue: 0.30) // 주황
        case .book:        return Color(red: 0.30, green: 0.72, blue: 0.55) // 초록
        case .movie:       return Color(red: 0.62, green: 0.45, blue: 0.92) // 보라
        case .musical:     return Color(red: 0.93, green: 0.40, blue: 0.62) // 핑크
        case .music:       return Color(red: 0.95, green: 0.45, blue: 0.45) // 빨강
        case .performance: return Color(red: 0.40, green: 0.78, blue: 0.88) // 청록
        }
    }

    /// 입력 폼에서 "만든 사람/장소" 필드의 라벨 (카테고리마다 다르게).
    var secondaryFieldLabel: String? {
        switch self {
        case .diary:       return nil
        case .photo:       return "장소"
        case .book:        return "저자"
        case .movie:       return "감독"
        case .musical:     return "극장 / 출연"
        case .music:       return "아티스트"
        case .performance: return "장소 / 출연"
        }
    }

    /// 별점을 쓰는 카테고리인가 (일기/사진은 별점 없음).
    var usesRating: Bool {
        switch self {
        case .diary, .photo: return false
        default:             return true
        }
    }

    /// "보고싶음 / 보는중 / 봤음" 상태를 쓰는 카테고리인가.
    var usesStatus: Bool {
        switch self {
        case .book, .movie, .musical, .performance: return true
        default:                                     return false
        }
    }

    /// 빠른 입력 그리드에 보일 순서
    static var quickAddOrder: [LogCategory] {
        [.diary, .photo, .book, .movie, .musical, .music, .performance]
    }
}
