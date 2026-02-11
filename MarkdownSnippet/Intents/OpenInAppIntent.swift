import AppIntents

struct OpenInAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open in MarkdownSnippet"
    static let isDiscoverable: Bool = false
    static let openAppWhenRun: Bool = true

    @Dependency private var store: DocumentStore

    @Parameter(title: "Markdown")
    var markdown: String

    init() {}

    init(markdown: String) {
        self.markdown = markdown
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let body = markdown.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else {
            return .result(dialog: "Opened MarkdownSnippet.")
        }

        store.createDocument(
            title: Self.makeTitle(from: body),
            content: body
        )
        return .result(dialog: "Opened MarkdownSnippet with a new document.")
    }

    private static func makeTitle(from markdown: String) -> String {
        let lines = markdown.components(separatedBy: .newlines)
        for rawLine in lines {
            var line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            while line.first == "#" {
                line.removeFirst()
            }
            line = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if line.isEmpty {
                continue
            }
            return String(line.prefix(80))
        }

        return "Imported Markdown"
    }
}
