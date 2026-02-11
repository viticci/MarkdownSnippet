import AppIntents
import Foundation
import UIKit
import UniformTypeIdentifiers

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
        let pasteboard = UIPasteboard.general

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

            if let rtfData {
                var item: [String: Any] = [
                    UTType.utf8PlainText.identifier: Data(nsAttributed.string.utf8)
                ]
                item[UTType.rtf.identifier] = rtfData
                pasteboard.setItems([item], options: [:])
            } else {
                pasteboard.string = nsAttributed.string
            }
        } else {
            pasteboard.string = markdown
        }

        PreviewMarkdownSnippetIntent.reload()

        return .result(dialog: "Copied to clipboard as rich text.")
    }
}
