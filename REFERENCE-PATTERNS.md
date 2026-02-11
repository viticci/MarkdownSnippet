# Reference Code Patterns for Interactive Snippet Intents

## 1. Basic SnippetIntent Structure

```swift
import AppIntents
import SwiftUI

struct MySnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "My Snippet"
    
    @Parameter(title: "Input")
    var input: String
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view: MySnippetView(input: input)
        )
    }
}
```

## 2. Interactive Buttons (MUST use Button(intent:))

```swift
struct MySnippetView: View {
    let data: String
    
    var body: some View {
        VStack {
            Text(data)
            
            // ✅ Interactive in snippets
            Button(intent: DoSomethingIntent(data: data)) {
                Label("Action", systemImage: "star")
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}
```

## 3. Refreshing Snippets via reload()

```swift
struct UpdateDataIntent: AppIntent {
    static let title: LocalizedStringResource = "Update Data"
    
    @Parameter var data: String
    
    func perform() async throws -> some IntentResult {
        // Process the data...
        
        // Trigger snippet refresh
        MySnippetIntent.reload()
        
        return .result()
    }
}
```

## 4. Chaining Snippets with requestConfirmation

```swift
struct WizardIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Wizard"
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Step 1
        try await requestConfirmation(
            actionName: .continue,
            snippetIntent: StepOneSnippetIntent()
        )
        
        // Step 2
        try await requestConfirmation(
            actionName: .continue,
            snippetIntent: StepTwoSnippetIntent()
        )
        
        return .result()
    }
}
```

## 5. OpensIntent for Flow Handoff

```swift
struct CollectInputIntent: AppIntent {
    static let title: LocalizedStringResource = "Collect Input"
    
    @Parameter(title: "User Text")
    var text: String
    
    func perform() async throws -> some IntentResult & OpensIntent {
        // Save the input...
        
        return .result(
            opensIntent: ContinueFlowIntent(text: text)
        )
    }
}
```

## 6. App Entity Pattern

```swift
struct DocumentEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Document")
    static let defaultQuery = DocumentQuery()
    
    let id: String
    let title: String
    let content: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct DocumentQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [DocumentEntity] {
        // Fetch from data store
        return []
    }
    
    func suggestedEntities() async throws -> [DocumentEntity] {
        // Return recent documents
        return []
    }
}
```

## 7. AppShortcutsProvider

```swift
struct MarkdownSnippetShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PreviewMarkdownIntent(),
            phrases: [
                "Preview markdown in \(.applicationName)",
                "Show markdown preview with \(.applicationName)"
            ],
            shortTitle: "Preview Markdown",
            systemImageName: "doc.richtext"
        )
    }
}
```

## 8. AttributedString from Markdown (Foundation built-in)

```swift
// Basic
let attributed = try AttributedString(markdown: "**Bold** and *italic*")

// Full CommonMark
let options = AttributedString.MarkdownParsingOptions(
    interpretedSyntax: .full
)
let attributed = try AttributedString(markdown: markdownString, options: options)

// In SwiftUI
Text(attributed)
```

## 9. Hiding Helper Intents from Shortcuts

```swift
struct InternalHelperIntent: AppIntent {
    static let title: LocalizedStringResource = "Internal Helper"
    
    // Hide from Shortcuts app
    static var isDiscoverable: Bool { false }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
```

## 10. Important Constraints

- Snippet views MUST be lightweight — `perform()` may be called multiple times
- Standard SwiftUI interaction (TextField, Toggle with @State) does NOT work in snippets
- Only `Button(intent:)` provides interactivity
- Snippets work in Shortcuts app and Siri, potentially Spotlight on macOS
- The SwiftUI view should be reasonably sized (not a full-screen app)
- Use `.reload()` to refresh snippet content after intent actions
