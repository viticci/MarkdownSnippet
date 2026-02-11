import AppIntents
import SwiftData

struct FindDocumentIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Markdown Document"
    static let description: IntentDescription = "Search for saved markdown documents"
    
    @Parameter(title: "Document", description: "The document to find")
    var document: MarkdownDocumentEntity?
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let document = document else {
            throw FindError.noDocumentSelected
        }
        
        return .result(
            view: MarkdownPreviewSnippetView(
                markdown: document.content,
                documentTitle: document.title
            )
        )
    }
    
    enum FindError: Error, CustomLocalizedStringResourceConvertible {
        case noDocumentSelected
        
        var localizedStringResource: LocalizedStringResource {
            "No document selected"
        }
    }
}
