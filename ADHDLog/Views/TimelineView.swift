import SwiftUI
import SwiftData

/// 메인 타임라인. 날짜별로 묶어 보여주고, 맨 위에 스트릭 현황을 띄운다.
struct TimelineView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.modelContext) private var context

    /// 최신순 전체 기록
    @Query(sort: \LogEntry.entryDate, order: .reverse) private var entries: [LogEntry]

    /// 카테고리 필터 (nil = 전체)
    @State private var filter: LogCategory?

    private var filtered: [LogEntry] {
        guard let filter else { return entries }
        return entries.filter { $0.category == filter }
    }

    /// 날짜(자정 기준)별 그룹, 최신순.
    private var grouped: [(day: Date, items: [LogEntry])] {
        let cal = Calendar.current
        let dict = Dictionary(grouping: filtered) { cal.startOfDay(for: $0.entryDate) }
        return dict.keys.sorted(by: >).map { ($0, dict[$0]!.sorted { $0.createdAt > $1.createdAt }) }
    }

    var body: some View {
        ZStack {
            Theme.background(for: scheme).ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: Theme.spacing, pinnedViews: []) {
                    StreakHeaderView(entries: entries)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    CategoryFilterBar(selected: $filter)

                    if grouped.isEmpty {
                        EmptyTimelineView(hasAnyEntries: !entries.isEmpty, filter: filter)
                            .padding(.top, 40)
                    } else {
                        ForEach(grouped, id: \.day) { group in
                            DaySection(day: group.day, items: group.items)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - 날짜 섹션

private struct DaySection: View {
    let day: Date
    let items: [LogEntry]
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Self.headerFormat(day))
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(items) { entry in
                    NavigationLink {
                        EntryDetailView(entry: entry)
                    } label: {
                        EntryRowView(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            context.delete(entry)
                            try? context.save()
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    static func headerFormat(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "오늘" }
        if cal.isDateInYesterday(date) { return "어제" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 (E)"
        return f.string(from: date)
    }
}

// MARK: - 카테고리 필터 바

private struct CategoryFilterBar: View {
    @Binding var selected: LogCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Chip(label: "전체", symbol: "square.grid.2x2",
                     tint: .gray, isOn: selected == nil) {
                    selected = nil
                }
                ForEach(LogCategory.allCases) { cat in
                    Chip(label: cat.label, symbol: cat.symbol,
                         tint: cat.tint, isOn: selected == cat) {
                        selected = (selected == cat) ? nil : cat
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private struct Chip: View {
        let label: String
        let symbol: String
        let tint: Color
        let isOn: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Label(label, systemImage: symbol)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isOn ? tint : Color(.secondarySystemBackground),
                                in: Capsule())
                    .foregroundStyle(isOn ? .white : .primary)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - 빈 상태 (죄책감 없이 부드럽게)

private struct EmptyTimelineView: View {
    let hasAnyEntries: Bool
    let filter: LogCategory?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: filter?.symbol ?? "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("오른쪽 위 + 버튼으로 가볍게 시작해요.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }

    private var message: String {
        if let filter { return "\(filter.label) 기록이 아직 없어요." }
        return hasAnyEntries ? "기록이 없어요." : "첫 기록을 남겨볼까요?"
    }
}

#Preview {
    NavigationStack {
        TimelineView()
    }
    .modelContainer(PersistenceController.preview)
}
