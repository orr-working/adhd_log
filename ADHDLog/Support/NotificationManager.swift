import Foundation
import UserNotifications

/// 매일 부드러운 리마인더. ADHD: "눈앞에서 사라지면 잊는다"를 보완하되, 채근하지 않는 톤.
enum NotificationManager {
    static let reminderID = "daily-reminder"

    /// 알림 권한 요청. 허용 여부 반환.
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// 현재 권한 상태.
    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// 설정값에 따라 매일 리마인더를 다시 예약(또는 해제).
    static func reschedule(enabled: Bool, hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "오늘 한 줄 어때요?"
        content.body = "일기·본 영화·들은 음악 뭐든 가볍게 남겨봐요. 한 줄이면 충분해요 🙂"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger)
        center.add(request)
    }
}
