import SwiftUI
import SwiftData
import AppIntents

@main
struct MarkdownSnippetApp: App {
    init() {
        // Make the shared store available to all App Intents via @Dependency.
        AppDependencyManager.shared.add(dependency: DocumentStore.shared)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MarkdownDocument.self)
    }
}
