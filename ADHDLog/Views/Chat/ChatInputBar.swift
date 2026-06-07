import SwiftUI
import PhotosUI

/// 채팅 입력 바: 카테고리 칩(자동 추측 강조) + 텍스트 + 전송.
struct ChatInputBar: View {
    @Binding var text: String
    /// 사용자가 직접 고른 카테고리 (nil = 자동 추측 모드)
    @Binding var forcedCategory: LogCategory?
    /// 첨부 예정 사진
    @Binding var pendingPhoto: Data?

    @FocusState.Binding var isFocused: Bool

    let onSend: () -> Void

    /// 자동 추측 결과 (칩 하이라이트용)
    private var guessed: LogCategory {
        forcedCategory ?? EntryParser.guessCategory(text, hasPhoto: pendingPhoto != nil)
    }

    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 8) {
            // 카테고리 칩
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    AutoChip(isOn: forcedCategory == nil) { forcedCategory = nil }
                    ForEach(LogCategory.allCases) { cat in
                        CatChip(
                            cat: cat,
                            isForced: forcedCategory == cat,
                            isGuessed: forcedCategory == nil && guessed == cat
                        ) {
                            forcedCategory = (forcedCategory == cat) ? nil : cat
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            // 첨부 사진 미리보기
            if let data = pendingPhoto, let image = UIImage(data: data) {
                HStack {
                    Image(uiImage: image)
                        .resizable().scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Button {
                        pendingPhoto = nil
                        photoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
            }

            // 입력 줄
            HStack(spacing: 10) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                TextField("뭐든 가볍게 적어요…", text: $text, axis: .vertical)
                    .lineLimit(1...5)
                    .focused($isFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(canSend ? Color.accentColor : Color(.tertiaryLabel))
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
        }
        .padding(.top, 8)
        .background(.bar)
        .onChange(of: photoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    pendingPhoto = data
                }
            }
        }
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || pendingPhoto != nil
    }

    // MARK: - 칩들

    private struct AutoChip: View {
        let isOn: Bool
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                Label("자동", systemImage: "wand.and.stars")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(isOn ? Color.accentColor : Color(.secondarySystemBackground), in: Capsule())
                    .foregroundStyle(isOn ? .white : .primary)
            }
            .buttonStyle(.plain)
        }
    }

    private struct CatChip: View {
        let cat: LogCategory
        let isForced: Bool
        let isGuessed: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Label(cat.label, systemImage: cat.symbol)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(background, in: Capsule())
                    .foregroundStyle(isForced ? .white : .primary)
                    .overlay(
                        Capsule().strokeBorder(
                            isGuessed ? cat.tint : .clear,
                            style: StrokeStyle(lineWidth: 1.5, dash: [3])
                        )
                    )
            }
            .buttonStyle(.plain)
        }

        private var background: Color {
            if isForced { return cat.tint }
            return Color(.secondarySystemBackground)
        }
    }
}
