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

            if let attributed = try? AttributedString(
                markdown: markdown,
                options: .init(interpretedSyntax: .full)
            ) {
                Text(attributed)
                    .font(.body)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(markdown)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack(spacing: 16) {
                Button(intent: CopyRichTextIntent(markdown: markdown)) {
                    Label("Copy Rich Text", systemImage: "doc.on.doc")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(intent: OpenInAppIntent()) {
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
