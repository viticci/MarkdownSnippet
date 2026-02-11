# MarkdownSnippet — Complete Build Prompt

Build a complete iOS 26 Xcode project called **MarkdownSnippet** — the first app to use interactive snippet intents for Markdown preview.

## What This App Does

A user runs a Shortcuts action, passes in Markdown text, and an **interactive snippet** appears showing the rendered rich text — headings, bold, italic, lists, code, links — all beautifully formatted. Buttons in the snippet let them copy as rich text or open in the full app. No other app does this.

## Step 1: Read the Reference Material

There are two files in this directory:
- `BRIEF.md` — full project spec with architecture and requirements
- `REFERENCE-PATTERNS.md` — code patterns for SnippetIntent, Button(intent:), reload(), AppEntity, AppShortcutsProvider

Read both before writing any code.

## Step 2: Create the Xcode Project

Use `xcodegen` with the existing `project.yml` in this directory. If xcodegen isn't installed: `brew install xcodegen`.

All Swift source files go under `MarkdownSnippet/`.

## Step 3: Implement Everything

### File Structure

```
MarkdownSnippet/
├── MarkdownSnippetApp.swift
├── Models/
│   ├── MarkdownDocument.swift
│   └── MarkdownDocumentEntity.swift
├── Views/
│   ├── ContentView.swift
│   ├── MarkdownEditorView.swift
│   └── MarkdownPreviewSnippetView.swift
├── Intents/
│   ├── PreviewMarkdownIntent.swift
│   ├── PreviewMarkdownSnippetIntent.swift
│   ├── FindDocumentIntent.swift
│   ├── ConvertMarkdownIntent.swift
│   ├── CopyRichTextIntent.swift
│   └── OpenInAppIntent.swift
├── AppShortcuts/
│   └── MarkdownSnippetShortcuts.swift
└── Assets.xcassets/
    ├── Contents.json
    └── AppIcon.appiconset/
        └── Contents.json
```

### 3a. MarkdownSnippetApp.swift

```swift
import SwiftUI
import SwiftData
import AppIntents

@main
struct MarkdownSnippetApp: App {
    init() {
        // Make the shared store available to all App Intents via @Dependency
        AppDependencyManager.shared.add(dependency: DocumentStore.shared)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MarkdownDocument.self)
    }
}
```

### 3b. Models/MarkdownDocument.swift

SwiftData model:

```swift
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
```

Also create a `DocumentStore` class that App Intents can use via `@Dependency`:

```swift
import SwiftData
import Foundation

@MainActor
final class DocumentStore: Sendable {
    static let shared = DocumentStore()
    
    private var container: ModelContainer?
    
    func getContainer() -> ModelContainer {
        if let container { return container }
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
```

### 3c. Models/MarkdownDocumentEntity.swift

```swift
import AppIntents
import Foundation

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
    
    func entities(for identifiers: [UUID]) async throws -> [MarkdownDocumentEntity] {
        await identifiers.compactMap { id in
            guard let doc = store.document(for: id) else { return nil }
            return MarkdownDocumentEntity(id: doc.id, title: doc.title, content: doc.content)
        }
    }
    
    func suggestedEntities() async throws -> [MarkdownDocumentEntity] {
        await store.allDocuments().prefix(10).map {
            MarkdownDocumentEntity(id: $0.id, title: $0.title, content: $0.content)
        }
    }
}
```

### 3d. Views/MarkdownPreviewSnippetView.swift — THE STAR

This is the key differentiator. Make it beautiful.

```swift
import SwiftUI
import AppIntents

struct MarkdownPreviewSnippetView: View {
    let markdown: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "doc.richtext")
                    .foregroundStyle(.blue)
                Text("Markdown Preview")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Rendered markdown content
            if let attributed = try? AttributedString(
                markdown: markdown,
                options: .init(interpretedSyntax: .full)
            ) {
                Text(attributed)
                    .font(.body)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(markdown)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Action buttons — MUST use Button(intent:) for snippet interactivity
            HStack(spacing: 16) {
                Button(intent: CopyRichTextIntent(markdown: markdown)) {
                    Label("Copy Rich Text", systemImage: "doc.on.doc")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                
                Spacer()
                
                Button(intent: OpenInAppIntent()) {
                    Label("Open in App", systemImage: "arrow.up.forward.app")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground).gradient)
        .clipShape(.containerRelative)
    }
}
```

### 3e. Intents/PreviewMarkdownIntent.swift — Entry Point

```swift
import AppIntents

struct PreviewMarkdownIntent: AppIntent {
    static let title: LocalizedStringResource = "Preview Markdown"
    static let description: IntentDescription = "Renders Markdown text as a rich text preview."
    
    @Parameter(title: "Markdown Text", description: "The Markdown content to preview")
    var markdownText: String
    
    init() {}
    
    init(markdownText: String) {
        self.markdownText = markdownText
    }
    
    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        return .result(
            snippetIntent: PreviewMarkdownSnippetIntent(markdownText: markdownText)
        )
    }
}
```

### 3f. Intents/PreviewMarkdownSnippetIntent.swift — The SnippetIntent

```swift
import AppIntents
import SwiftUI

struct PreviewMarkdownSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Markdown Preview Snippet"
    static let isDiscoverable: Bool = false
    
    @Parameter(title: "Markdown Text")
    var markdownText: String
    
    init() {}
    
    init(markdownText: String) {
        self.markdownText = markdownText
    }
    
    // perform() must be lightweight — called multiple times during snippet lifecycle
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view: MarkdownPreviewSnippetView(markdown: markdownText)
        )
    }
}
```

### 3g. Intents/CopyRichTextIntent.swift

```swift
import AppIntents
import UIKit

struct CopyRichTextIntent: AppIntent {
    static let title: LocalizedStringResource = "Copy as Rich Text"
    static let isDiscoverable: Bool = false
    
    @Parameter(title: "Markdown")
    var markdown: String
    
    init() {}
    
    init(markdown: String) {
        self.markdown = markdown
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let attributed = try? NSAttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .full)
        ) {
            let rtfData = try? attributed.data(
                from: NSRange(location: 0, length: attributed.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            )
            
            let pasteboard = UIPasteboard.general
            if let rtfData {
                pasteboard.setValue(rtfData, forPasteboardType: "public.rtf")
            }
            pasteboard.string = attributed.string
        }
        
        // Refresh the snippet view
        PreviewMarkdownSnippetIntent.reload()
        
        return .result(dialog: "Copied to clipboard as rich text.")
    }
}
```

### 3h. Intents/OpenInAppIntent.swift

```swift
import AppIntents

struct OpenInAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open in MarkdownSnippet"
    static let isDiscoverable: Bool = false
    static let openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
```

### 3i. Intents/ConvertMarkdownIntent.swift

```swift
import AppIntents
import Foundation

struct ConvertMarkdownIntent: AppIntent {
    static let title: LocalizedStringResource = "Convert Markdown to Rich Text"
    static let description: IntentDescription = "Converts Markdown text into rich text."
    
    @Parameter(title: "Markdown Text")
    var markdownText: String
    
    init() {}
    
    init(markdownText: String) {
        self.markdownText = markdownText
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        if let attributed = try? AttributedString(
            markdown: markdownText,
            options: .init(interpretedSyntax: .full)
        ) {
            let plainText = String(attributed.characters)
            return .result(value: plainText, dialog: "Converted Markdown to rich text.")
        }
        return .result(value: markdownText, dialog: "Could not parse Markdown.")
    }
}
```

### 3j. Intents/FindDocumentIntent.swift

```swift
import AppIntents

struct FindDocumentIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Markdown Document"
    static let description: IntentDescription = "Finds a saved Markdown document and shows a preview."
    
    @Parameter(title: "Document")
    var document: MarkdownDocumentEntity
    
    init() {}
    
    init(document: MarkdownDocumentEntity) {
        self.document = document
    }
    
    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        return .result(
            snippetIntent: PreviewMarkdownSnippetIntent(markdownText: document.content)
        )
    }
}
```

### 3k. Views/ContentView.swift

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MarkdownDocument.modifiedAt, order: .reverse) private var documents: [MarkdownDocument]
    @State private var showingNewDocument = false
    
    var body: some View {
        NavigationStack {
            Group {
                if documents.isEmpty {
                    ContentUnavailableView {
                        Label("No Documents", systemImage: "doc.richtext")
                    } description: {
                        Text("Create a Markdown document or use the Preview Markdown shortcut.")
                    } actions: {
                        Button("New Document") {
                            createDocument()
                        }
                    }
                } else {
                    List {
                        ForEach(documents) { doc in
                            NavigationLink(destination: MarkdownEditorView(document: doc)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(doc.title)
                                        .font(.headline)
                                    Text(doc.content.prefix(80))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                    Text(doc.modifiedAt, style: .relative)
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteDocuments)
                    }
                }
            }
            .navigationTitle("MarkdownSnippet")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: createDocument) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func createDocument() {
        let doc = MarkdownDocument(
            title: "New Document",
            content: "# Hello\n\nStart writing **Markdown** here."
        )
        modelContext.insert(doc)
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(documents[index])
        }
    }
}
```

### 3l. Views/MarkdownEditorView.swift

```swift
import SwiftUI

struct MarkdownEditorView: View {
    @Bindable var document: MarkdownDocument
    @State private var showPreview = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Title field
            TextField("Title", text: $document.title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 8)
            
            Divider()
                .padding(.vertical, 8)
            
            if showPreview {
                // Rich text preview
                ScrollView {
                    if let attributed = try? AttributedString(
                        markdown: document.content,
                        options: .init(interpretedSyntax: .full)
                    ) {
                        Text(attributed)
                            .font(.body)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                }
            } else {
                // Markdown editor
                TextEditor(text: $document.content)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
            }
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showPreview.toggle() }) {
                    Image(systemName: showPreview ? "pencil" : "eye")
                }
            }
        }
        .onChange(of: document.content) {
            document.modifiedAt = Date()
        }
        .onChange(of: document.title) {
            document.modifiedAt = Date()
        }
    }
}
```

### 3m. AppShortcuts/MarkdownSnippetShortcuts.swift

```swift
import AppIntents

struct MarkdownSnippetShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PreviewMarkdownIntent(),
            phrases: [
                "Preview markdown in \(.applicationName)",
                "Show markdown preview with \(.applicationName)",
                "Render markdown using \(.applicationName)"
            ],
            shortTitle: "Preview Markdown",
            systemImageName: "doc.richtext"
        )
        
        AppShortcut(
            intent: FindDocumentIntent(),
            phrases: [
                "Find document in \(.applicationName)",
                "Open a document from \(.applicationName)"
            ],
            shortTitle: "Find Document",
            systemImageName: "magnifyingglass"
        )
    }
}
```

## Step 4: Generate Xcode Project & Commit

```bash
cd ~/Projects/MarkdownSnippet
xcodegen generate
git add -A
git commit -m "feat: Complete MarkdownSnippet iOS 26 app with interactive snippet intents for Markdown preview"
```

## Step 5: Verify

- `find MarkdownSnippet -name "*.swift" | wc -l` should show 13 files
- `ls MarkdownSnippet.xcodeproj` should exist
- The project should open in Xcode 26 and build for iOS 26.0

## Key Constraints Recap

- **Button(intent:)** is the ONLY way to get interactive buttons in snippets
- **SnippetIntent.perform()** must be lightweight — it gets called multiple times
- **AttributedString(markdown:options:)** with `.full` interpretedSyntax handles CommonMark
- **@Parameter** + explicit `init()` required on all intents that take parameters
- **isDiscoverable = false** on helper intents to hide them from Shortcuts
- **@Dependency** for shared state between intents and the app
