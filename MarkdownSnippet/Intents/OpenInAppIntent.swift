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
        let body = markdown.sanitizedMarkdownInput().trimmingCharacters(in: .whitespacesAndNewlines)
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
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            if let attributed = MarkdownRichText.attributedString(from: line) {
                let plain = String(attributed.characters).trimmingCharacters(in: .whitespacesAndNewlines)
                if !plain.isEmpty {
                    return String(plain.prefix(80))
                }
            } else {
                return String(line.prefix(80))
            }
        }

        return "Imported Markdown"
    }
}
