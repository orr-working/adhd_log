import SwiftUI
import SwiftData
import PhotosUI

/// 기록 입력/편집 폼. 카테고리에 따라 필요한 칸만 보여줘 부담을 줄인다.
/// 핵심 원칙: "비어 있어도 저장 가능" — 무엇 하나라도 남기면 기록이 된다.
struct EntryEditView: View {
    @Bindable var entry: LogEntry
    /// true 면 새 기록(저장 시 context 에 insert), false 면 기존 기록 편집.
    let isNew: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var photoItem: PhotosPickerItem?

    private var category: LogCategory { entry.category }

    var body: some View {
        NavigationStack {
            Form {
                // 카테고리 (새 기록일 때만 변경 가능)
                Section {
                    HStack {
                        Label(category.label, systemImage: category.symbol)
                            .foregroundStyle(category.tint)
                            .font(.headline)
                        Spacer()
                        if isNew {
                            Menu {
                                ForEach(LogCategory.allCases) { c in
                                    Button {
                                        entry.category = c
                                    } label: {
                                        Label(c.label, systemImage: c.symbol)
                                    }
                                }
                            } label: {
                                Text("변경")
                            }
                        }
                    }
                }

                // 제목 (일기는 선택)
                Section {
                    if category != .diary {
                        TextField(titlePlaceholder, text: $entry.title)
                            .font(.body.weight(.medium))
                    }
                    if let label = category.secondaryFieldLabel {
                        TextField(label, text: $entry.creator)
                    }
                }

                // 본문 / 메모
                Section(category == .diary ? "오늘" : "메모") {
                    TextField(notePlaceholder, text: $entry.note, axis: .vertical)
                        .lineLimit(3...8)
                }

                // 기분 (일기에서 특히 유용)
                Section("기분") {
                    MoodPicker(mood: Binding(
                        get: { entry.mood },
                        set: { entry.mood = $0 }
                    ))
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                }

                // 별점 + 상태 (미디어)
                if category.usesRating || category.usesStatus {
                    Section {
                        if category.usesRating {
                            HStack {
                                Text("별점")
                                Spacer()
                                RatingView(rating: $entry.rating, size: 24)
                            }
                        }
                        if category.usesStatus {
                            Picker("상태", selection: Binding(
                                get: { entry.status ?? .done },
                                set: { entry.status = $0 }
                            )) {
                                ForEach(LogStatus.allCases) { s in
                                    Label(s.label, systemImage: s.symbol).tag(s)
                                }
                            }
                        }
                    }
                }

                // 사진
                Section("사진") {
                    PhotoField(entry: entry, photoItem: $photoItem)
                }

                // 날짜
                Section {
                    DatePicker("날짜", selection: $entry.entryDate, displayedComponents: .date)
                }
            }
            .navigationTitle(isNew ? "새 기록" : "기록 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { save() }
                        .fontWeight(.semibold)
                        .disabled(isEmpty)
                }
            }
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        entry.photoData = data
                    }
                }
            }
        }
    }

    /// 아무것도 안 적었으면 저장 비활성화 (단, 사진/기분만 있어도 저장 가능).
    private var isEmpty: Bool {
        entry.title.isEmpty && entry.note.isEmpty && entry.creator.isEmpty
            && entry.photoData == nil && entry.mood == nil && entry.rating == 0
    }

    private func save() {
        if isNew {
            context.insert(entry)
        }
        try? context.save()
        WidgetReloader.reload()
        dismiss()
    }

    private var titlePlaceholder: String {
        switch category {
        case .book:        return "책 제목"
        case .movie:       return "영화 제목"
        case .musical:     return "뮤지컬 제목"
        case .music:       return "곡 / 앨범"
        case .performance: return "공연 제목"
        case .photo:       return "한 줄 캡션 (선택)"
        default:           return "제목"
        }
    }

    private var notePlaceholder: String {
        category == .diary ? "오늘 있었던 일, 한 줄도 좋아요" : "감상이나 메모 (선택)"
    }
}

// MARK: - 사진 첨부 필드

private struct PhotoField: View {
    @Bindable var entry: LogEntry
    @Binding var photoItem: PhotosPickerItem?

    var body: some View {
        if let data = entry.photoData, let image = UIImage(data: data) {
            VStack(spacing: 10) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius, style: .continuous))
                HStack {
                    PhotosPicker("사진 바꾸기", selection: $photoItem, matching: .images)
                    Spacer()
                    Button("삭제", role: .destructive) {
                        entry.photoData = nil
                        photoItem = nil
                    }
                }
                .font(.subheadline)
            }
        } else {
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("사진 추가", systemImage: "photo.badge.plus")
            }
        }
    }
}

#Preview {
    EntryEditView(entry: LogEntry(category: .book), isNew: true)
        .modelContainer(PersistenceController.preview)
}
