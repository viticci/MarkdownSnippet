import Foundation
import SwiftData

@Model
final class MarkdownDocument {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date

    init(title: String = "Untitled", content: String = "") {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

@MainActor
final class DocumentStore: Sendable {
    nonisolated static let shared = DocumentStore()

    private var container: ModelContainer?

    func getContainer() -> ModelContainer {
        if let container {
            return container
        }

        let container = try! ModelContainer(for: MarkdownDocument.self)
        self.container = container
        return container
    }

    func allDocuments() -> [MarkdownDocument] {
        let context = getContainer().mainContext
        let descriptor = FetchDescriptor<MarkdownDocument>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func document(for id: UUID) -> MarkdownDocument? {
        let descriptor = FetchDescriptor<MarkdownDocument>(
            predicate: #Predicate { $0.id == id }
        )
        return try? getContainer().mainContext.fetch(descriptor).first
    }
}
