import AppIntents
import Foundation
import UIKit
import UniformTypeIdentifiers

struct CopyRichTextV2Intent: AppIntent {
    static let title: LocalizedStringResource = "Copy as Rich Text"
    static let isDiscoverable: Bool = false
    static let openAppWhenRun: Bool = true

    @Parameter(title: "Markdown")
    var markdown: String

    init() {}

    init(markdown: String) {
        self.markdown = markdown
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let pasteboard = UIPasteboard.general
        let sanitizedMarkdown = markdown.sanitizedMarkdownInput()
        let plainText = MarkdownRichText.plainText(from: sanitizedMarkdown)

        if let nsAttributed = MarkdownRichText.nsAttributedString(from: sanitizedMarkdown, includeLinks: true) {
            let rtfData = try? nsAttributed.data(
                from: NSRange(location: 0, length: nsAttributed.length),
                documentAttributes: [
                    NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf
                ]
            )
            let htmlData = try? nsAttributed.data(
                from: NSRange(location: 0, length: nsAttributed.length),
                documentAttributes: [
                    NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html
                ]
            )

            if let rtfData {
                var item: [String: Any] = [
                    UTType.rtf.identifier: rtfData
                ]
                if let htmlData {
                    item[UTType.html.identifier] = htmlData
                }
                item[UTType.plainText.identifier] = plainText
                item[UTType.utf8PlainText.identifier] = Data(plainText.utf8)
                pasteboard.setItems([item], options: [:])
            } else {
                pasteboard.string = plainText
            }
        } else {
            pasteboard.string = sanitizedMarkdown
        }

        PreviewMarkdownSnippetIntent.reload()
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "LastCopyTimestamp")

        return .result(dialog: "Copied to clipboard as rich text.")
    }
}
