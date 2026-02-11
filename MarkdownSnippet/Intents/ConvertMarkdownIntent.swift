import AppIntents
import Foundation

struct ConvertMarkdownIntent: AppIntent {
    static let title: LocalizedStringResource = "Convert Markdown to Rich Text"
    static let description: IntentDescription = "Convert markdown text to rich text output"
    
    @Parameter(title: "Markdown Text", description: "The markdown content to convert")
    var markdownText: String
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full
        )
        
        guard let attributed = try? AttributedString(markdown: markdownText, options: options) else {
            throw ConversionError.failed
        }
        
        // Return plain text version of attributed string
        let plainText = String(attributed.characters)
        
        return .result(value: plainText)
    }
    
    enum ConversionError: Error, CustomLocalizedStringResourceConvertible {
        case failed
        
        var localizedStringResource: LocalizedStringResource {
            "Failed to convert markdown"
        }
    }
}
