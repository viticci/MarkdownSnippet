# MarkdownSnippet — iOS 26 App with Interactive Snippet Intents

## Mission

Build an iOS 26 app called **MarkdownSnippet** that lets users preview Markdown content as rendered rich text using the new **interactive snippet intents** in iOS 26's App Intents framework. This would be the FIRST app to use interactive snippets for Markdown preview — nobody has built this yet.

## What Are Interactive Snippets?

Interactive snippets are a new iOS 26 feature where App Intents can return SwiftUI views that display inline in Shortcuts, Spotlight, and Siri. They use `SnippetIntent` protocol. Key concepts:

- `SnippetIntent` — a protocol that requires `perform()` to return `ShowsSnippetView`
- `.result(view:)` — returns a SwiftUI view to render in the snippet
- `Button(intent:)` — the ONLY way to make buttons interactive in snippets (standard Button closures don't work)
- `.reload()` — static method on SnippetIntent to refresh the view
- `requestConfirmation(actionName:snippetIntent:)` — chains snippet views together
- `OpensIntent` — hands off flow from one intent to another

## App Requirements

### Core App
1. **Markdown Editor** — Simple text editor view where users can write/paste Markdown
2. **Live Preview** — Side-by-side or toggle preview showing rendered rich text
3. **Document Storage** — Save markdown documents locally (SwiftData or file-based)
4. **Share Extension** — Accept text/markdown from other apps

### Shortcuts Integration (THE KEY FEATURE)
1. **"Preview Markdown" App Intent** — Takes markdown text as input parameter
   - Returns an interactive snippet showing the rendered rich text
   - The snippet should display: headings, bold, italic, lists, code blocks, links
   - Include a "Copy as Rich Text" button (using `Button(intent:)`)
   - Include an "Open in App" button

2. **"Find Document" App Intent** — Find saved markdown documents
   - Returns a snippet preview of the document content

3. **"Convert Markdown" App Intent** — Takes markdown, outputs rich text
   - Non-snippet action for piping in Shortcuts

### App Entity
- `MarkdownDocumentEntity` — represents a saved document
- Properties: id, title, content (markdown), preview (first N chars), lastModified

## Technical Architecture

### SnippetIntent Pattern (from Apple's documentation)

```swift
struct PreviewMarkdownSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Preview Markdown"
    
    @Parameter(title: "Markdown Text")
    var markdownText: String
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view: MarkdownPreviewSnippetView(markdown: markdownText)
        )
    }
}
```

### SwiftUI View for Snippet

```swift
struct MarkdownPreviewSnippetView: View {
    let markdown: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Render markdown as AttributedString
            if let attributed = try? AttributedString(markdown: markdown, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                Text(attributed)
                    .font(.body)
            } else {
                Text(markdown)
                    .font(.body)
            }
            
            HStack {
                Button(intent: CopyRichTextIntent(markdown: markdown)) {
                    Label("Copy Rich Text", systemImage: "doc.on.doc")
                }
                .buttonStyle(.plain)
                
                Button(intent: OpenInAppIntent()) {
                    Label("Open in App", systemImage: "arrow.up.forward.app")
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}
```

### Markdown Rendering

Use `AttributedString(markdown:)` which is built into Foundation since iOS 15. For more complex rendering (code blocks, tables), consider using a custom parser or the `cmark` library.

For best results, use `AttributedString(markdown:options:)` with `.init(interpretedSyntax: .full)` to get full CommonMark support including:
- Headings (rendered with appropriate font sizes)
- Bold/italic/strikethrough
- Inline code
- Links (tappable)
- Lists (bullet and numbered)
- Block quotes

### Interactive Buttons in Snippets

Remember: ONLY `Button(intent:)` works in snippets. Standard SwiftUI buttons are not interactive.

```swift
// ✅ This works in snippets
Button(intent: SomeAppIntent()) {
    Text("Tap Me")
}

// ❌ This does NOT work in snippets
Button("Tap Me") {
    // action closure - won't fire
}
```

### Project Structure

```
MarkdownSnippet/
├── MarkdownSnippetApp.swift
├── Models/
│   ├── MarkdownDocument.swift          # SwiftData model
│   └── MarkdownDocumentEntity.swift    # App Entity
├── Views/
│   ├── ContentView.swift               # Main editor/list view
│   ├── MarkdownEditorView.swift        # Editor with preview
│   └── MarkdownPreviewSnippetView.swift # Snippet SwiftUI view
├── Intents/
│   ├── PreviewMarkdownIntent.swift     # Main snippet intent
│   ├── PreviewMarkdownSnippetIntent.swift # SnippetIntent
│   ├── FindDocumentIntent.swift        # Find documents
│   ├── ConvertMarkdownIntent.swift     # Convert action
│   ├── CopyRichTextIntent.swift        # Copy button intent
│   └── OpenInAppIntent.swift           # Open in app intent
├── AppShortcuts/
│   └── MarkdownSnippetShortcuts.swift  # AppShortcutsProvider
└── Assets.xcassets/
```

## Key References

- WWDC25 Session 275: "Explore new advances in App Intents" — https://developer.apple.com/videos/play/wwdc2025/275/
- WWDC25 Session 281: "Design interactive snippets" — https://developer.apple.com/videos/play/wwdc2025/281/
- Apple Docs: "Displaying static and interactive snippets" — https://developer.apple.com/documentation/AppIntents/displaying-static-and-interactive-snippets
- Nutrient blog (excellent code examples): https://www.nutrient.io/blog/wwdc25-snippet-intents/
- Superwall tutorial (CaffeinePal example): https://superwall.com/blog/app-intents-interactive-snippets-in-ios-26/
- Sample code: https://github.com/PSPDFKit-labs/Snippet-Intents-WWDC25

## Deployment Target

- iOS 26.0 minimum
- Swift 6.x / Xcode 26
- Use SwiftUI throughout
- Use SwiftData for document persistence

## What Makes This Special

This is the FIRST app to use iOS 26's interactive snippet intents for Markdown preview. The key innovation is:
1. You run a Shortcut action → pass in any Markdown text
2. An interactive snippet appears showing the RENDERED rich text preview
3. You can tap buttons to copy, share, or open in the full editor
4. No need to open any app — the preview lives right in Shortcuts/Spotlight

This fills a genuine gap in the iOS ecosystem that no developer has addressed yet.
