import Foundation
import SwiftData

@Model
final class MarkdownDocument {
    @Attribute(.unique) var id: String
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date
    
    init(id: String = UUID().uuidString, title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    var preview: String {
        String(content.prefix(200))
    }
}
