import AppIntents
import SwiftData

/// Lets the user find a saved Markdown document and preview it as a snippet.
struct FindDocumentIntent: AppIntent {

    static let title: LocalizedStringResource = "Find Markdown Document"
    static let description: IntentDescription = "Search for a saved Markdown document and show a preview snippet."

    @Parameter(title: "Document")
    var document: MarkdownDocumentEntity

    init() {}

    init(document: MarkdownDocumentEntity) {
        self.document = document
    }

    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let snippet = PreviewMarkdownSnippetIntent()
        snippet.markdownText = document.content
        return .result(opensIntent: snippet)
    }
}
