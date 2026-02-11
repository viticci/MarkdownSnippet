import SwiftUI
import AppIntents

struct MarkdownPreviewSnippetView: View {
    let markdown: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.richtext")
                    .foregroundStyle(.blue)
                Text("Markdown Preview")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            Divider()
            
            MarkdownRenderView(
                markdown: markdown,
                compact: false,
                transparentTextBackground: true
            )
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            HStack(spacing: 16) {
                Button(intent: CopyRichTextV2Intent(markdown: markdown)) {
                    Label("Copy Rich Text", systemImage: "doc.on.doc")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(intent: OpenInAppIntent(markdown: markdown)) {
                    Label("Open in App", systemImage: "arrow.up.forward.app")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground).gradient)
        .clipShape(.containerRelative)
    }
}
