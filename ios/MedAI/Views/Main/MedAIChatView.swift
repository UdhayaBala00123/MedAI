
import SwiftUI

struct MedAIChatView: View {
    private struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }

    @State private var messages: [ChatMessage] = [
        ChatMessage(
            text: "Hello! I'm MedAI Assistant. What would you like to know about health?",
            isUser: false
        )
    ]

    @State private var inputText = ""
    @State private var isSending = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }

                        if isSending {
                            HStack {
                                ProgressView()
                                Text("MedAI is thinking...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    guard let lastID = messages.last?.id else { return }
                    withAnimation {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 6)
            }

            Divider()

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Ask MedAI...", text: $inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isSending)

                Button {
                    Task {
                        await sendMessage()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue)
                }
                .disabled(
                    inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || isSending
                )
            }
            .padding()
        }
        .navigationTitle("MedAI Assistant")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 45)
            }

            Text(message.text)
                .textSelection(.enabled)
                .padding(12)
                .background(
                    message.isUser
                        ? Color.blue
                        : Color(.secondarySystemBackground)
                )
                .foregroundStyle(message.isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if !message.isUser {
                Spacer(minLength: 45)
            }
        }
    }

    @MainActor
    private func sendMessage() async {
        let question = inputText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !question.isEmpty, !isSending else { return }

        inputText = ""
        errorMessage = nil

        messages.append(
            ChatMessage(text: question, isUser: true)
        )

        isSending = true
        defer { isSending = false }

        do {
            let reply = try await AIChatService.shared.sendMessage(question)

            messages.append(
                ChatMessage(text: reply, isUser: false)
            )
        } catch {
            errorMessage = "Couldn't reach MedAI. Check your connection and try again."
        }
    }
}

#Preview {
    NavigationStack {
        MedAIChatView()
    }
}
