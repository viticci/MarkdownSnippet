import Foundation
import SwiftData

@Model
final class MarkdownDocument {

    @Attribute(.unique)
    var id: UUID

    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "Untitled",
        content: String = "",
        createdAt: Date = .now,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    /// First 140 characters of the content, suitable for display representations.
    var preview: String {
        String(content.prefix(140))
    }
}
