import AppIntents
import SwiftUI

struct PreviewMarkdownIntent: AppIntent {
    static let title: LocalizedStringResource = "Preview Markdown"
    static let description: IntentDescription = "Preview markdown text as rendered rich text"
    
    @Parameter(title: "Markdown Text", description: "The markdown content to preview")
    var markdownText: String
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view: MarkdownPreviewSnippetView(markdown: markdownText)
        )
    }
}
