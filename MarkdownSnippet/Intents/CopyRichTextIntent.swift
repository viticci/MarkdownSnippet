import AppIntents
import UIKit
import Foundation

/// Copies the given Markdown content as rich text (NSAttributedString) to the clipboard.
/// Hidden from Shortcuts — only triggered via Button(intent:) inside the snippet view.
struct CopyRichTextIntent: AppIntent {

    static let title: LocalizedStringResource = "Copy as Rich Text"
    static let isDiscoverable: Bool = false

    @Parameter(title: "Markdown Text")
    var markdownText: String

    init() {}

    init(markdown: String) {
        self.markdownText = markdown
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full
        )

        if let attributed = try? AttributedString(markdown: markdownText, options: options) {
            let nsAttributed = NSAttributedString(attributed)
            if let rtfData = try? nsAttributed.data(
                from: NSRange(location: 0, length: nsAttributed.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            ) {
                UIPasteboard.general.setData(rtfData, forPasteboardType: "public.rtf")
            }
        }

        // Refresh the snippet to give visual feedback
        PreviewMarkdownSnippetIntent.reload()

        return .result()
    }
}
