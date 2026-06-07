import Foundation
import SwiftData

/// 앱과 위젯이 같은 데이터를 보도록 App Group 컨테이너에 SwiftData 저장소를 만든다.
/// iCloud(CloudKit) 동기화는 entitlements 의 CloudKit 컨테이너 설정으로 자동 활성화된다.
enum AppGroup {
    /// ⚠️ 본인 App Group ID 와 일치해야 한다 (README 의 설정 단계 참고).
    static let identifier = "group.com.adhdlog.shared"
}

enum PersistenceController {

    /// 앱 전역에서 공유하는 ModelContainer.
    static let shared: ModelContainer = makeContainer()

    private static func makeContainer() -> ModelContainer {
        let schema = Schema([LogEntry.self])

        // App Group 안에 저장소 파일을 둬서 위젯에서도 읽을 수 있게 한다.
        let storeURL = containerURL.appending(path: "ADHDLog.store")

        let config = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .automatic   // iCloud 동기화 (entitlements 필요)
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // App Group/iCloud 설정 전에도 미리보기·로컬 실행이 가능하도록 폴백.
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return (try? ModelContainer(for: schema, configurations: [fallback]))
                ?? (try! ModelContainer(for: schema,
                                        configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]))
        }
    }

    private static var containerURL: URL {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)
            ?? URL.documentsDirectory
    }

    /// SwiftUI 미리보기용 인메모리 컨테이너 (샘플 데이터 포함).
    @MainActor
    static let preview: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: LogEntry.self, configurations: config)
        SampleData.insert(into: container.mainContext)
        return container
    }()
}
