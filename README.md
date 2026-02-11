# MarkdownSnippet

MarkdownSnippet is an iOS/iPadOS app that renders Markdown as rich text and exposes that rendering through App Intents, including interactive snippet views for Shortcuts.

The core flow:

1. Run `Preview Markdown` from Shortcuts.
2. Pass Markdown text as input.
3. See a rendered interactive snippet with actions to copy rich text or open the app.

## Features

- Markdown editor with local document storage (SwiftData).
- In-app preview mode powered by `AttributedString(markdown:options:)`.
- App Intents integration for Shortcuts.
- Interactive snippet UI using `SnippetIntent`.
- Snippet actions using `Button(intent:)`:
  - `Copy as Rich Text`
  - `Open in MarkdownSnippet`
- Document entity lookup via `Find Markdown Document`.

## Tech Stack

- Swift 6
- SwiftUI
- SwiftData
- App Intents (`AppIntent`, `SnippetIntent`, `AppEntity`, `AppShortcutsProvider`)
- XcodeGen for project generation

## Requirements

- macOS with Xcode 26+
- iOS/iPadOS 26.0+ deployment target
- `xcodegen` installed
- Optional: GitHub CLI (`gh`) for repo automation

Install XcodeGen if needed:

```bash
brew install xcodegen
```

## Project Structure

```text
MarkdownSnippet/
├── MarkdownSnippet/
│   ├── AppShortcuts/
│   │   └── MarkdownSnippetShortcuts.swift
│   ├── Intents/
│   │   ├── ConvertMarkdownIntent.swift
│   │   ├── CopyRichTextIntent.swift
│   │   ├── FindDocumentIntent.swift
│   │   ├── OpenInAppIntent.swift
│   │   ├── PreviewMarkdownIntent.swift
│   │   └── PreviewMarkdownSnippetIntent.swift
│   ├── Models/
│   │   ├── MarkdownDocument.swift
│   │   └── MarkdownDocumentEntity.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── MarkdownEditorView.swift
│   │   └── MarkdownPreviewSnippetView.swift
│   ├── Assets.xcassets/
│   └── MarkdownSnippetApp.swift
├── MarkdownSnippet.xcodeproj/
├── project.yml
└── README.md
```

## Build From Source

1. Clone the repository:

```bash
git clone https://github.com/viticci/MarkdownSnippet.git
cd MarkdownSnippet
```

2. Generate the Xcode project:

```bash
xcodegen generate
```

3. Open the project:

```bash
open MarkdownSnippet.xcodeproj
```

4. In Xcode, select the `MarkdownSnippet` scheme and build.

## Install on iOS and iPadOS (Device)

1. Connect your iPhone or iPad to your Mac.
2. Open `MarkdownSnippet.xcodeproj` in Xcode.
3. Select the `MarkdownSnippet` target.
4. In **Signing & Capabilities**:
   - Choose your Apple Developer team.
   - If needed, change bundle identifier to a unique value (for example `com.yourname.MarkdownSnippet`).
5. Select your physical device as the run destination.
6. Press `Cmd+R` to build and install.
7. If prompted on device, enable Developer Mode:
   - **Settings > Privacy & Security > Developer Mode**.
8. If app trust is required:
   - **Settings > General > VPN & Device Management** and trust the developer app certificate.

## Run in Simulator

```bash
xcodebuild -project MarkdownSnippet.xcodeproj \
  -scheme MarkdownSnippet \
  -destination 'generic/platform=iOS Simulator' \
  build
```

## Using the App

1. Launch **MarkdownSnippet**.
2. Tap `+` to create a document.
3. Edit Markdown in the text editor.
4. Tap the eye icon to toggle preview.

## Using Shortcuts

After installing and launching the app once, Shortcuts should index the app intents.

### Intent: `Preview Markdown`

- Input: `Markdown Text` (`String`)
- Output: Interactive snippet (`PreviewMarkdownSnippetIntent`)
- Snippet actions:
  - `Copy Rich Text` (copies RTF + plain text to clipboard)
  - `Open in App` (opens MarkdownSnippet)

### Intent: `Find Markdown Document`

- Input: `MarkdownDocumentEntity`
- Output: Interactive snippet preview of selected document content

### Intent: `Convert Markdown to Rich Text`

- Input: Markdown text
- Output: converted plain-text representation and dialog status

## Architecture Notes

- `MarkdownSnippetApp` registers `DocumentStore` into `AppDependencyManager` so intents can resolve shared state via `@Dependency`.
- `MarkdownDocument` is the SwiftData model.
- `MarkdownDocumentEntity` + `MarkdownDocumentQuery` expose stored documents to App Intents.
- `PreviewMarkdownIntent` returns `ShowsSnippetIntent` and launches `PreviewMarkdownSnippetIntent`.
- `PreviewMarkdownSnippetIntent` returns `ShowsSnippetView` with `MarkdownPreviewSnippetView`.
- Snippet interactivity is implemented with `Button(intent:)` only.

## Troubleshooting

- Intents not visible in Shortcuts:
  - Launch the app once after install.
  - Rebuild and reinstall from Xcode.
  - Reopen Shortcuts.
- Signing errors:
  - Ensure a valid Apple team is selected.
  - Use a unique bundle ID.
- Build issues after changes:
  - Regenerate project with `xcodegen generate`.
  - Clean build folder in Xcode (`Shift+Cmd+K`).

## Status

- Project generated via XcodeGen.
- Verified build with Xcode 26 simulator target.
