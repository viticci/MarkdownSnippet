import AppIntents
import Foundation

/// A pipeline-friendly intent: takes Markdown text and returns the rendered rich text
/// as an AttributedString. Useful for chaining in Shortcuts without showing a snippet.
struct ConvertMarkdownIntent: AppIntent {

    static let title: LocalizedStringResource = "Convert Markdown to Rich Text"
    static let description: IntentDescription = "Converts Markdown text into styled rich text."

    @Parameter(title: "Markdown Text")
    var markdownText: String

    init() {}

    init(markdownText: String) {
        self.markdownText = markdownText
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full
        )

        if let attributed = try? AttributedString(markdown: markdownText, options: options) {
            // Return the plain-text representation; the rich version lives in AttributedString
            let plain = String(attributed.characters)
            return .result(value: plain)
        }

        return .result(value: markdownText)
    }
}
