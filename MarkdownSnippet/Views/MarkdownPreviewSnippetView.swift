import SwiftUI
import AppIntents

/// The key snippet view — renders Markdown as rich text with interactive intent-driven buttons.
/// This view is displayed inline in Shortcuts, Siri, and Spotlight.
struct MarkdownPreviewSnippetView: View {

    let markdown: String

    private var renderedMarkdown: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full
        )
        return (try? AttributedString(markdown: markdown, options: options))
            ?? AttributedString(markdown)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // MARK: Rendered Content
            Text(renderedMarkdown)
                .font(.body)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .padding(.vertical, 4)

            // MARK: Interactive Buttons (intent-driven — the ONLY way in snippets)
            HStack(spacing: 16) {
                Button(intent: CopyRichTextIntent(markdown: markdown)) {
                    Label("Copy Rich Text", systemImage: "doc.on.doc")
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.bordered)
                .tint(.blue)

                Button(intent: OpenInAppIntent()) {
                    Label("Open in App", systemImage: "arrow.up.forward.app")
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}
