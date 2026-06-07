import SwiftUI
import SwiftData

/// 메인 채팅 화면. 기록을 말풍선으로 쌓고, 하단 입력 바로 가볍게 추가한다.
struct ChatView: View {
    /// 위젯 딥링크로 들어온 빠른 입력 요청 (카테고리 미리 선택 + 키보드 포커스).
    @Binding var incoming: QuickAddRequest?

    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    @Query(sort: \LogEntry.entryDate, order: .forward) private var entries: [LogEntry]

    @State private var text = ""
    @State private var forcedCategory: LogCategory?
    @State private var pendingPhoto: Data?
    @State private var followUp: FollowUp?
    @FocusState private var isFocused: Bool

    private let bottomAnchor = "BOTTOM"

    private var items: [ChatItem] { ChatComposer.build(from: entries) }
    private var streak: Int { StreakCalculator.currentStreak(from: entries) }
    private var didToday: Bool { StreakCalculator.didLogToday(entries) }

    var body: some View {
        VStack(spacing: 0) {
            streakPill

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        if entries.isEmpty {
                            WelcomeBubble()
                                .padding(.top, 12)
                        }

                        ForEach(items) { item in
                            row(for: item)
                        }

                        if let followUp {
                            FollowUpBubble(
                                followUp: followUp,
                                onRating: { applyRating($0) },
                                onStatus: { applyStatus($0) },
                                onCreator: { applyCreator($0) },
                                onSkip: { withAnimation { self.followUp = nil } }
                            )
                            .transition(.opacity)
                        }

                        Color.clear.frame(height: 1).id(bottomAnchor)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: entries.count) { scrollToBottom(proxy) }
                .onChange(of: followUp) { scrollToBottom(proxy) }
                .onAppear { scrollToBottom(proxy, animated: false) }
            }

            ChatInputBar(
                text: $text,
                forcedCategory: $forcedCategory,
                pendingPhoto: $pendingPhoto,
                isFocused: $isFocused,
                onSend: send
            )
        }
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .onChange(of: incoming, initial: true) { _, request in
            guard let request else { return }
            forcedCategory = request.category
            isFocused = true
            incoming = nil
        }
    }

    // MARK: - 상단 스트릭 알약

    private var streakPill: some View {
        HStack(spacing: 8) {
            Image(systemName: streak > 0 ? "flame.fill" : "flame")
                .foregroundStyle(streak > 0 ? Theme.streak : .secondary)
            Text(streak > 0 ? "\(streak)일 연속" : "오늘부터 시작")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text(didToday ? "오늘 완료 ✓" : "오늘도 한 줄이면 이어져요")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }

    // MARK: - 행 렌더링

    @ViewBuilder
    private func row(for item: ChatItem) -> some View {
        switch item {
        case .monthSummary(let s):
            MonthSummaryCard(summary: s)
        case .daySeparator(let d):
            DaySeparatorView(day: d)
        case .entry(let e):
            NavigationLink {
                EntryDetailView(entry: e)
            } label: {
                ChatBubbleView(entry: e)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 전송 / 되묻기

    private func send() {
        let raw = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty || pendingPhoto != nil else { return }

        let result = EntryParser.parse(raw, forcedCategory: forcedCategory, hasPhoto: pendingPhoto != nil)
        let entry = LogEntry(category: result.category)
        if result.category == .diary || result.category == .photo {
            entry.note = result.cleanedText
        } else {
            entry.title = result.cleanedText
        }
        entry.rating = result.rating
        entry.photoData = pendingPhoto

        context.insert(entry)
        try? context.save()
        WidgetReloader.reload()

        text = ""
        pendingPhoto = nil
        forcedCategory = nil
        withAnimation { followUp = FollowUpEngine.next(for: entry) }
    }

    private func entry(for box: PersistentIdentifierBox) -> LogEntry? {
        context.model(for: box.id) as? LogEntry
    }

    private func applyRating(_ value: Int) {
        guard let fu = followUp, let e = entry(for: fu.entryID) else { return }
        e.rating = value
        finishFollowUp()
    }

    private func applyStatus(_ status: LogStatus) {
        guard let fu = followUp, let e = entry(for: fu.entryID) else { return }
        e.status = status
        finishFollowUp()
    }

    private func applyCreator(_ creator: String) {
        guard let fu = followUp, let e = entry(for: fu.entryID) else { return }
        e.creator = creator.trimmingCharacters(in: .whitespacesAndNewlines)
        finishFollowUp()
    }

    private func finishFollowUp() {
        try? context.save()
        WidgetReloader.reload()
        withAnimation { followUp = nil }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
            } else {
                proxy.scrollTo(bottomAnchor, anchor: .bottom)
            }
        }
    }
}

/// 첫 사용 안내 말풍선 (봇 톤, 부담 없이).
private struct WelcomeBubble: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("안녕하세요 👋")
                    .font(.subheadline.weight(.semibold))
                Text("오늘 뭐 했는지, 본 영화·읽은 책·들은 음악 뭐든 아래에 가볍게 적어보세요. 별점은 ⭐로 같이 써도 알아서 인식해요.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer(minLength: 40)
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(incoming: .constant(nil))
    }
    .modelContainer(PersistenceController.preview)
}
