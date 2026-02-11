import AppIntents

struct OpenInAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open in MarkdownSnippet"
    static let isDiscoverable: Bool = false
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
