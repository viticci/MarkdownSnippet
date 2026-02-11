import AppIntents

struct MarkdownSnippetShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PreviewMarkdownIntent(),
            phrases: [
                "Preview markdown in \(.applicationName)",
                "Show markdown preview with \(.applicationName)",
                "Render markdown using \(.applicationName)"
            ],
            shortTitle: "Preview Markdown",
            systemImageName: "doc.richtext"
        )

        AppShortcut(
            intent: FindDocumentIntent(),
            phrases: [
                "Find document in \(.applicationName)",
                "Open a document from \(.applicationName)",
                "Search \(.applicationName) documents"
            ],
            shortTitle: "Find Document",
            systemImageName: "magnifyingglass"
        )

        AppShortcut(
            intent: ConvertMarkdownIntent(),
            phrases: [
                "Convert markdown with \(.applicationName)",
                "Turn markdown into rich text using \(.applicationName)"
            ],
            shortTitle: "Convert Markdown",
            systemImageName: "arrow.right.doc.on.clipboard"
        )
    }
}
