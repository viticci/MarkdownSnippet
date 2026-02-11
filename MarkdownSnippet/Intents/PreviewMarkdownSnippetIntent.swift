import AppIntents
import SwiftUI

struct PreviewMarkdownSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Markdown Preview Snippet"
    static let isDiscoverable: Bool = false

    @Parameter(title: "Markdown Text")
    var markdownText: String

    init() {}

    init(markdownText: String) {
        self.markdownText = markdownText
    }

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view: MarkdownPreviewSnippetView(markdown: markdownText)
        )
    }
}
