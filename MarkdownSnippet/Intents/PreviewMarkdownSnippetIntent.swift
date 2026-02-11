import AppIntents
import SwiftUI

/// The SnippetIntent that renders an interactive Markdown preview inline.
struct PreviewMarkdownSnippetIntent: SnippetIntent {

    static let title: LocalizedStringResource = "Markdown Preview Snippet"
    static let description: IntentDescription = "Displays rendered Markdown as a rich-text snippet."
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
