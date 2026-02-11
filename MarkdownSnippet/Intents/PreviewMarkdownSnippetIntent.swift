import AppIntents
import SwiftUI
import Foundation

struct PreviewMarkdownSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Markdown Preview Snippet"
    static let isDiscoverable: Bool = false

    @Parameter(title: "Payload ID")
    var payloadID: String

    init() {}

    init(payloadID: String) {
        self.payloadID = payloadID
    }

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let markdown = Self.markdown(for: payloadID)

        return .result(
            view: MarkdownPreviewSnippetView(markdown: markdown)
        )
    }

    static func storeMarkdown(_ markdown: String) -> String {
        let payloadID = UUID().uuidString
        UserDefaults.standard.set(markdown, forKey: payloadKey(for: payloadID))
        return payloadID
    }

    static func markdown(for payloadID: String) -> String {
        UserDefaults.standard.string(forKey: payloadKey(for: payloadID)) ?? ""
    }

    private static func payloadKey(for id: String) -> String {
        "SnippetMarkdownPayload.\(id)"
    }
}
