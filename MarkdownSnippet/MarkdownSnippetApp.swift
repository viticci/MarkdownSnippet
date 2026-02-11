import SwiftUI
import SwiftData

@main
struct MarkdownSnippetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MarkdownDocument.self)
    }
}
