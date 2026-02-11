# MarkdownSnippet

MarkdownSnippet is an iOS/iPadOS app + App Intents toolkit for rendering Markdown inside Shortcuts snippets and in a native editor app.

## Current Status (February 11, 2026)

The project is currently tuned around a real Shortcuts rendering bug observed on iOS 26.x where snippet previews could show a yellow highlight bar with a red prohibited glyph over rendered content.

The current implementation keeps snippet rendering stable while preserving:

- Rich Markdown rendering in the snippet (headings, links, images, tables, code blocks).
- Responsive horizontal scrolling for Markdown tables.
- Working snippet buttons (`Copy Rich Text`, `Open in App`).
- Reliable clipboard writes from the snippet action.

## What Was Happening

Symptoms seen in Shortcuts snippet UI:

- Yellow horizontal artifact over preview text.
- Red prohibited symbol in the highlighted area.
- Behavior changed depending on markdown length and action state.

The issue appears to be in Shortcuts/snippet rendering state, not in markdown parsing itself.

## Final Mitigation Strategy

The current code uses a hybrid mitigation that keeps rich rendering and working buttons:

- Snippet payload indirection:
  - `PreviewMarkdownIntent` stores markdown in `UserDefaults` and passes only a payload ID to the snippet intent.
  - This avoids passing large raw markdown directly in snippet intent parameters.
- Aggressive input sanitization:
  - Filters problematic scalars (format/private-use/control/illegal marker code points) before render/copy/open.
- Rich snippet renderer with transparent text background:
  - Uses `swift-markdown-ui` theme customization to avoid clashing background artifacts.
- Copy action reliability + cache busting:
  - Copy action now uses a renamed intent type (`CopyRichTextV2Intent`) and foreground run mode.
  - This forces Shortcuts/App Intents re-indexing and improves clipboard reliability.

## Copy Behavior

`Copy Rich Text` now writes a multi-format pasteboard payload:

- `public.rtf`
- `public.html`
- plain text (`public.plain-text` + UTF-8)

Notes:

- The destination app decides which representation to consume.
- Some destinations may still flatten links/formatting on paste (app-specific behavior).
- The app may foreground when copy runs (`openAppWhenRun = true`) to improve reliability.

## Markdown Rendering Behavior

- Snippet preview uses full markdown rendering (not plain text fallback by default).
- Tables are rendered with horizontal scrolling.
- Table rows are styled with alternating backgrounds.
- Images are constrained and rounded.
- Code blocks are horizontally scrollable.

## Key Files

- `MarkdownSnippet/Intents/PreviewMarkdownIntent.swift`
- `MarkdownSnippet/Intents/PreviewMarkdownSnippetIntent.swift`
- `MarkdownSnippet/Intents/CopyRichTextIntent.swift`
- `MarkdownSnippet/Intents/OpenInAppIntent.swift`
- `MarkdownSnippet/Models/MarkdownSanitizer.swift`
- `MarkdownSnippet/Models/MarkdownRichText.swift`
- `MarkdownSnippet/Views/MarkdownRenderView.swift`
- `MarkdownSnippet/Views/MarkdownPreviewSnippetView.swift`
- `MarkdownSnippet/Views/MarkdownSnapshotView.swift`

## Troubleshooting (Shortcuts/App Intents Cache)

If behavior looks stale after installing a new build:

1. Launch `MarkdownSnippet` once manually.
2. Force-quit Shortcuts and reopen.
3. Re-run the shortcut.
4. If still stale, remove and re-add the action in Shortcuts.

## Tech Stack

- Swift 6
- SwiftUI
- SwiftData
- App Intents + SnippetIntent APIs
- XcodeGen
- `swift-markdown-ui` (`swift-cmark` GFM support)

## Requirements

- macOS with Xcode 26+
- iOS/iPadOS deployment target: 26.0
- Homebrew + `xcodegen`

Install XcodeGen:

```bash
brew install xcodegen
```

## Project Layout

```text
MarkdownSnippet/
├── MarkdownSnippet/
│   ├── AppShortcuts/
│   ├── Assets.xcassets/
│   ├── Intents/
│   ├── Models/
│   ├── Views/
│   └── MarkdownSnippetApp.swift
├── ICON_COMPOSER_NOTES.md
├── project.yml
└── README.md
```

## Build From Source

```bash
git clone https://github.com/viticci/MarkdownSnippet.git
cd MarkdownSnippet
xcodegen generate
open MarkdownSnippet.xcodeproj
```

Then select scheme `MarkdownSnippet` in Xcode and build.

### CLI Build Check

```bash
xcodebuild -project MarkdownSnippet.xcodeproj \
  -scheme MarkdownSnippet \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build
```

## Install on iPhone/iPad

1. Connect the device to your Mac.
2. In Xcode, select target `MarkdownSnippet`.
3. In Signing, set your Team and ensure bundle ID is valid for your account.
4. Select the physical device as run destination.
5. Build and run (`Cmd+R`).
6. Launch the app once so Shortcuts can index intents.

## Icon Asset Notes

- PNG fallback icon is included in `Assets.xcassets`.
- Liquid Glass/Icon Composer workflow notes are in `ICON_COMPOSER_NOTES.md`.
