import AppIntents

struct FindDocumentIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Markdown Document"
    static let description: IntentDescription = "Finds a saved Markdown document and shows a preview."

    @Parameter(title: "Document")
    var document: MarkdownDocumentEntity

    init() {}

    init(document: MarkdownDocumentEntity) {
        self.document = document
    }

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        let payloadID = PreviewMarkdownSnippetIntent.storeMarkdown(document.content)
        return .result(
            snippetIntent: PreviewMarkdownSnippetIntent(payloadID: payloadID)
        )
    }
}
