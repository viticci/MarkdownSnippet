import SwiftUI
import AppIntents

struct MarkdownPreviewSnippetView: View {
    let markdown: String
    var documentTitle: String?
    
    @State private var attributedText: AttributedString?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Document title if provided
            if let title = documentTitle {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            // Rendered markdown content
            Group {
                if let attributed = attributedText {
                    Text(attributed)
                        .font(.body)
                        .textSelection(.enabled)
                } else {
                    Text(markdown)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Interactive buttons (must use Button(intent:))
            HStack(spacing: 16) {
                Button(intent: CopyRichTextIntent(markdown: markdown)) {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                
                Button(intent: OpenInAppIntent(markdown: markdown)) {
                    Label("Open", systemImage: "arrow.up.forward.app")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .task {
            await renderMarkdown()
        }
    }
    
    private func renderMarkdown() async {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full
        )
        
        attributedText = try? AttributedString(markdown: markdown, options: options)
    }
}

#Preview {
    MarkdownPreviewSnippetView(
        markdown: """
        # Sample Markdown
        
        This is **bold** and this is *italic*.
        
        - Item one
        - Item two
        - Item three
        
        Here's some `inline code` and a [link](https://example.com).
        """,
        documentTitle: "Preview Document"
    )
}
