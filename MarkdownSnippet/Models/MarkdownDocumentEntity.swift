import AppIntents
import SwiftData
import Foundation

struct MarkdownDocumentEntity: AppEntity {

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Markdown Document")
    static let defaultQuery = MarkdownDocumentQuery()

    let id: String
    let title: String
    let content: String
    let modifiedAt: Date

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(String(content.prefix(80)))"
        )
    }
}

// MARK: - Entity Query

struct MarkdownDocumentQuery: EntityQuery {

    @Dependency
    private var modelContainer: ModelContainer

    func entities(for identifiers: [String]) async throws -> [MarkdownDocumentEntity] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<MarkdownDocument>()
        let documents = try context.fetch(descriptor)
        let idSet = Set(identifiers)
        return documents
            .filter { idSet.contains($0.id.uuidString) }
            .map { $0.toEntity() }
    }

    func suggestedEntities() async throws -> [MarkdownDocumentEntity] {
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<MarkdownDocument>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 20
        let documents = try context.fetch(descriptor)
        return documents.map { $0.toEntity() }
    }
}

// MARK: - Convenience

extension MarkdownDocument {
    func toEntity() -> MarkdownDocumentEntity {
        MarkdownDocumentEntity(
            id: id.uuidString,
            title: title,
            content: content,
            modifiedAt: modifiedAt
        )
    }
}
