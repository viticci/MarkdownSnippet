import AppIntents

/// Opens the MarkdownSnippet app. Used as a Button(intent:) action inside snippet views.
struct OpenInAppIntent: AppIntent {

    static let title: LocalizedStringResource = "Open in MarkdownSnippet"
    static let isDiscoverable: Bool = false
    static let openAppWhenRun: Bool = true

    init() {}

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
