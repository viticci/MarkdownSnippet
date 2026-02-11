import Foundation
import AppIntents

struct MarkdownDocumentEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Markdown Document")
    static let defaultQuery = MarkdownDocumentQuery()

    let id: UUID
    let title: String
    let content: String
    let preview: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(preview)")
    }

    init(id: UUID, title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
        self.preview = String(content.prefix(100))
    }
}

struct MarkdownDocumentQuery: EntityQuery {
    @Dependency var store: DocumentStore

    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [MarkdownDocumentEntity] {
        identifiers.compactMap { id in
            guard let document = store.document(for: id) else {
                return nil
            }
            return MarkdownDocumentEntity(id: document.id, title: document.title, content: document.content)
        }
    }

    @MainActor
    func suggestedEntities() async throws -> [MarkdownDocumentEntity] {
        Array(store.allDocuments().prefix(10)).map {
            MarkdownDocumentEntity(id: $0.id, title: $0.title, content: $0.content)
        }
    }
}
