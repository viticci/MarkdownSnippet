import AppIntents
import Foundation

struct ConvertMarkdownIntent: AppIntent {
    static let title: LocalizedStringResource = "Convert Markdown to Rich Text"
    static let description: IntentDescription = "Converts Markdown text into rich text."

    @Parameter(title: "Markdown Text")
    var markdownText: String

    init() {}

    init(markdownText: String) {
        self.markdownText = markdownText
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        if let attributed = try? AttributedString(
            markdown: markdownText,
            options: .init(interpretedSyntax: .full)
        ) {
            let plainText = String(attributed.characters)
            return .result(value: plainText, dialog: "Converted Markdown to rich text.")
        }
        return .result(value: markdownText, dialog: "Could not parse Markdown.")
    }
}
