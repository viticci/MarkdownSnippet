import AppIntents

/// Main user-facing intent: takes markdown text and shows an interactive snippet preview.
struct PreviewMarkdownIntent: AppIntent {

    static let title: LocalizedStringResource = "Preview Markdown"
    static let description: IntentDescription = "Render Markdown text as a rich-text snippet with interactive actions."

    @Parameter(title: "Markdown Text")
    var markdownText: String

    init() {}

    init(markdownText: String) {
        self.markdownText = markdownText
    }

    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let snippet = PreviewMarkdownSnippetIntent()
        snippet.markdownText = markdownText
        return .result(opensIntent: snippet)
    }
}
