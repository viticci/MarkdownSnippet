import SwiftUI
import SwiftData
import AppIntents

@main
struct MarkdownSnippetApp: App {

    let container: ModelContainer

    init() {
        // Register the dependency manager so App Intents can resolve the container
        let container = try! ModelContainer(for: MarkdownDocument.self)
        self.container = container
        AppDependencyManager.shared.add(dependency: container)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
