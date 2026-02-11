import AppIntents
import SwiftUI

struct PreviewMarkdownSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Preview Markdown Snippet"
    
    @Parameter(title: "Markdown Text")
    var markdownText: String
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view: MarkdownPreviewSnippetView(markdown: markdownText)
        )
    }
}
