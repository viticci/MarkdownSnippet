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
                "Find markdown document in \(.applicationName)",
                "Open document in \(.applicationName)"
            ],
            shortTitle: "Find Document",
            systemImageName: "magnifyingglass"
        )
        
        AppShortcut(
            intent: ConvertMarkdownIntent(),
            phrases: [
                "Convert markdown with \(.applicationName)",
                "Transform markdown using \(.applicationName)"
            ],
            shortTitle: "Convert Markdown",
            systemImageName: "arrow.2.squarepath"
        )
    }
}
