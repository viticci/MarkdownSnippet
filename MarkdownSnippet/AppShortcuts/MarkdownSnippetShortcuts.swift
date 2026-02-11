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
                "Open a document from \(.applicationName)"
            ],
            shortTitle: "Find Document",
            systemImageName: "magnifyingglass"
        )
    }
}
