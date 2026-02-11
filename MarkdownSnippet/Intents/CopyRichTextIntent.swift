import AppIntents
import Foundation

#if canImport(UIKit)
import UIKit
#endif

struct CopyRichTextIntent: AppIntent {
    static let title: LocalizedStringResource = "Copy Rich Text"
    static let description: IntentDescription = "Copy markdown as rich text to clipboard"
    static var isDiscoverable: Bool { false }
    
    @Parameter(title: "Markdown Text")
    var markdown: String
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Convert markdown to AttributedString
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full
        )
        
        guard let attributed = try? AttributedString(markdown: markdown, options: options) else {
            throw CopyError.conversionFailed
        }
        
        #if canImport(UIKit)
        // Convert to NSAttributedString for pasteboard
        let nsAttributed = try NSAttributedString(attributed)
        UIPasteboard.general.string = nsAttributed.string
        #endif
        
        return .result(dialog: "Rich text copied to clipboard")
    }
    
    enum CopyError: Error, CustomLocalizedStringResourceConvertible {
        case conversionFailed
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .conversionFailed:
                return "Failed to convert markdown to rich text"
            }
        }
    }
}
