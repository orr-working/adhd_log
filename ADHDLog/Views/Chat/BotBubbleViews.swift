import SwiftUI

/// 날짜 구분선.
struct DaySeparatorView: View {
    let day: Date

    var body: some View {
        HStack {
            line
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            line
        }
        .padding(.vertical, 4)
    }

    private var line: some View {
        Rectangle().fill(Color(.separator)).frame(height: 0.5)
    }

    private var label: String {
        let cal = Calendar.current
        if cal.isDateInToday(day) { return "오늘" }
        if cal.isDateInYesterday(day) { return "어제" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 (E)"
        return f.string(from: day)
    }
}

/// 월 요약 카드 = 왼쪽(봇) 말풍선. "이번 달 영화 7편" 같은 성취 요약.
struct MonthSummaryCard: View {
    let summary: MonthSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text(summary.title)
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.secondary)

                if summary.total == 0 {
                    Text("아직 기록이 없어요. 가볍게 시작해요 🙂")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("총 \(summary.total)개 기록")
                        .font(.headline)

                    FlowChips(items: SummaryBuilder.lines(summary))

                    if let highlight = summary.highlight {
                        Label("최고의 한 편: \(highlight)", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer(minLength: 40)
        }
    }
}

/// 작은 칩들을 줄바꿈 배치.
private struct FlowChips: View {
    let items: [String]
    var body: some View {
        // 간단한 2열 배치 (위젯/카드 폭에 충분).
        let columns = [GridItem(.adaptive(minimum: 80), spacing: 6)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { text in
                Text(text)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.secondarySystemBackground), in: Capsule())
            }
        }
    }
}

/// 가벼운 되묻기 = 왼쪽(봇) 말풍선. 항상 "건너뛰기" 제공.
struct FollowUpBubble: View {
    let followUp: FollowUp
    let onRating: (Int) -> Void
    let onStatus: (LogStatus) -> Void
    let onCreator: (String) -> Void
    let onSkip: () -> Void

    @State private var creatorText = ""

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(FollowUpEngine.prompt(for: followUp.kind))
                    .font(.subheadline)

                switch followUp.kind {
                case .rating:
                    RatingStars(onPick: onRating)
                case .status:
                    HStack(spacing: 8) {
                        ForEach(LogStatus.allCases) { s in
                            Button {
                                onStatus(s)
                            } label: {
                                Label(s.label, systemImage: s.symbol)
                                    .font(.caption.weight(.medium))
                                    .padding(.horizontal, 10).padding(.vertical, 6)
                                    .background(Color(.secondarySystemBackground), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                case .creator:
                    HStack {
                        TextField("입력", text: $creatorText)
                            .textFieldStyle(.roundedBorder)
                        Button("확인") { onCreator(creatorText) }
                            .disabled(creatorText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Button("건너뛰기", action: onSkip)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer(minLength: 40)
        }
    }

    private struct RatingStars: View {
        let onPick: (Int) -> Void
        var body: some View {
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: "star")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .onTapGesture { onPick(i) }
                }
            }
        }
    }
}
