import AppIntents
import Foundation
import UIKit

struct CopyRichTextIntent: AppIntent {
    static let title: LocalizedStringResource = "Copy as Rich Text"
    static let isDiscoverable: Bool = false

    @Parameter(title: "Markdown")
    var markdown: String

    init() {}

    init(markdown: String) {
        self.markdown = markdown
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let attributed = try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .full),
        ) {
            let nsAttributed = NSAttributedString(attributed)
            let rtfData = try? nsAttributed.data(
                from: NSRange(location: 0, length: nsAttributed.length),
                documentAttributes: [
                    NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf
                ]
            )

            let pasteboard = UIPasteboard.general
            if let rtfData {
                pasteboard.setValue(rtfData, forPasteboardType: "public.rtf")
            }
            pasteboard.string = nsAttributed.string
        }

        PreviewMarkdownSnippetIntent.reload()

        return .result(dialog: "Copied to clipboard as rich text.")
    }
}
