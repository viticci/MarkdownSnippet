import Foundation
import AppIntents
import SwiftData

struct MarkdownDocumentEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Markdown Document")
    static let defaultQuery = MarkdownDocumentQuery()
    
    let id: String
    let title: String
    let content: String
    let preview: String
    let modifiedAt: Date
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(preview)"
        )
    }
    
    init(from document: MarkdownDocument) {
        self.id = document.id
        self.title = document.title
        self.content = document.content
        self.preview = document.preview
        self.modifiedAt = document.modifiedAt
    }
}

struct MarkdownDocumentQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [MarkdownDocumentEntity] {
        let context = try getModelContext()
        let descriptor = FetchDescriptor<MarkdownDocument>(
            predicate: #Predicate { document in
                identifiers.contains(document.id)
            }
        )
        let documents = try context.fetch(descriptor)
        return documents.map { MarkdownDocumentEntity(from: $0) }
    }
    
    @MainActor
    func suggestedEntities() async throws -> [MarkdownDocumentEntity] {
        let context = try getModelContext()
        var descriptor = FetchDescriptor<MarkdownDocument>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 10
        let documents = try context.fetch(descriptor)
        return documents.map { MarkdownDocumentEntity(from: $0) }
    }
    
    @MainActor
    private func getModelContext() throws -> ModelContext {
        let container = try ModelContainer(for: MarkdownDocument.self)
        return ModelContext(container)
    }
}
