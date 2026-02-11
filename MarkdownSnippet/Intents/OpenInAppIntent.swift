import AppIntents
import Foundation

struct OpenInAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open in App"
    static let description: IntentDescription = "Open MarkdownSnippet app"
    static var isDiscoverable: Bool { false }
    
    @Parameter(title: "Markdown Text", default: "")
    var markdown: String?
    
    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        // This will open the app
        return .result()
    }
}
