import SwiftUI
import SwiftData

/// 기록 상세 보기. 편집/삭제 가능.
struct EntryDetailView: View {
    @Bindable var entry: LogEntry
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 헤더
                HStack(spacing: 10) {
                    Image(systemName: entry.category.symbol)
                        .foregroundStyle(entry.category.tint)
                    Text(entry.category.label)
                        .foregroundStyle(entry.category.tint)
                        .font(.headline)
                    Spacer()
                    Text(entry.entryDate, format: .dateTime.year().month().day())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.title2.weight(.bold))
                }

                if !entry.creator.isEmpty {
                    Text(entry.creator)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    if let mood = entry.mood {
                        Text("\(mood.emoji) \(mood.label)")
                            .font(.subheadline)
                    }
                    if let status = entry.status {
                        Label(status.label, systemImage: status.symbol)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if entry.category.usesRating && entry.rating > 0 {
                    RatingView(rating: .constant(entry.rating), size: 22, interactive: false)
                }

                if let data = entry.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                }

                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showingEdit = true } label: {
                        Label("편집", systemImage: "pencil")
                    }
                    Button(role: .destructive) { showingDeleteConfirm = true } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EntryEditView(entry: entry, isNew: false)
        }
        .confirmationDialog("이 기록을 삭제할까요?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                context.delete(entry)
                try? context.save()
                WidgetReloader.reload()
                dismiss()
            }
            Button("취소", role: .cancel) {}
        }
    }
}
