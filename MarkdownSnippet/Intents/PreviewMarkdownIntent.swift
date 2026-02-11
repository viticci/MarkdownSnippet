import AppIntents

struct PreviewMarkdownIntent: AppIntent {
    static let title: LocalizedStringResource = "Preview Markdown"
    static let description: IntentDescription = "Renders Markdown text as a rich text preview."

    @Parameter(title: "Markdown Text", description: "The Markdown content to preview")
    var markdownText: String

    init() {}

    init(markdownText: String) {
        self.markdownText = markdownText
    }

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        let payloadID = PreviewMarkdownSnippetIntent.storeMarkdown(markdownText)

        return .result(
            snippetIntent: PreviewMarkdownSnippetIntent(payloadID: payloadID)
        )
    }
}
