import WidgetKit

/// 데이터가 바뀌면 위젯을 갱신하도록 요청한다.
enum WidgetReloader {
    static func reload() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
