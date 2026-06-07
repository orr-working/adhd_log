import SwiftUI
import SwiftData

/// 과거 기록 검색 + 카테고리/별점 필터.
struct SearchView: View {
    @Environment(\.colorScheme) private var scheme
    @Query(sort: \LogEntry.entryDate, order: .reverse) private var entries: [LogEntry]

    @State private var query = ""
    @State private var category: LogCategory?
    @State private var minRating = 0

    private var results: [LogEntry] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return entries.filter { e in
            if let category, e.category != category { return false }
            if minRating > 0 && e.rating < minRating { return false }
            guard !q.isEmpty else { return true }
            return e.title.lowercased().contains(q)
                || e.note.lowercased().contains(q)
                || e.creator.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            Theme.background(for: scheme).ignoresSafeArea()

            VStack(spacing: 0) {
                filters

                if results.isEmpty {
                    ContentUnavailableView(
                        query.isEmpty ? "기록을 검색해요" : "결과가 없어요",
                        systemImage: "magnifyingglass",
                        description: Text(query.isEmpty ? "단어로 찾거나 위에서 필터를 골라보세요." : "다른 단어나 필터로 시도해보세요.")
                    )
                    Spacer()
                } else {
                    List {
                        Section {
                            ForEach(results) { entry in
                                NavigationLink {
                                    EntryDetailView(entry: entry)
                                } label: {
                                    EntrySearchRow(entry: entry)
                                }
                            }
                        } header: {
                            Text("\(results.count)개")
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("검색")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "제목·메모·이름")
    }

    private var filters: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    chip(label: "전체", symbol: "square.grid.2x2", tint: .gray, isOn: category == nil) {
                        category = nil
                    }
                    ForEach(LogCategory.allCases) { c in
                        chip(label: c.label, symbol: c.symbol, tint: c.tint, isOn: category == c) {
                            category = (category == c) ? nil : c
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            HStack(spacing: 8) {
                Text("별점").font(.caption).foregroundStyle(.secondary)
                ForEach(0...5, id: \.self) { r in
                    Button {
                        minRating = r
                    } label: {
                        Text(r == 0 ? "전체" : "\(r)★↑")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(minRating == r ? Color.accentColor : Color(.secondarySystemBackground), in: Capsule())
                            .foregroundStyle(minRating == r ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
    }

    private func chip(label: String, symbol: String, tint: Color, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: symbol)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(isOn ? tint : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(isOn ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

/// 검색 결과 한 줄.
private struct EntrySearchRow: View {
    let entry: LogEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(entry.category.tint.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: entry.category.symbol)
                    .foregroundStyle(entry.category.tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayTitle)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(entry.entryDate, format: .dateTime.year().month().day())
                    if !entry.creator.isEmpty { Text("· \(entry.creator)").lineLimit(1) }
                    if entry.rating > 0 { Text("· \(entry.rating)★") }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            if let data = entry.photoData, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    NavigationStack { SearchView() }
        .modelContainer(PersistenceController.preview)
}
