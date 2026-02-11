import SwiftUI
import SwiftData

struct MarkdownEditorView: View {

    @Bindable var document: MarkdownDocument
    @Environment(\.modelContext) private var modelContext
    @State private var showingPreview = false

    private var renderedMarkdown: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full
        )
        return (try? AttributedString(markdown: document.content, options: options))
            ?? AttributedString(document.content)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title field
            TextField("Title", text: $document.title)
                .font(.title2.weight(.semibold))
                .padding(.horizontal)
                .padding(.top, 8)
                .onChange(of: document.title) {
                    document.modifiedAt = .now
                }

            Divider()
                .padding(.top, 8)

            if showingPreview {
                // MARK: Preview Mode
                ScrollView {
                    Text(renderedMarkdown)
                        .font(.body)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .transition(.move(edge: .trailing))
            } else {
                // MARK: Editor Mode
                TextEditor(text: $document.content)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .onChange(of: document.content) {
                        document.modifiedAt = .now
                    }
                    .transition(.move(edge: .leading))
            }
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showingPreview.toggle()
                    }
                } label: {
                    Image(systemName: showingPreview ? "pencil" : "eye")
                }
            }
        }
        .onDisappear {
            try? modelContext.save()
        }
    }
}
