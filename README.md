# MarkdownSnippet

MarkdownSnippet is an iOS/iPadOS app + App Intents toolkit for rendering Markdown in Shortcuts snippet views and in a native editor app.

It is designed for the iOS 26/iPadOS 26 App Intents snippet workflow:

1. A shortcut sends Markdown text into `Preview Markdown`.
2. The app returns an interactive snippet with rendered output.
3. Snippet actions let you copy rich text (RTF) or create/open a document in the app.

## What It Supports

- Headings, paragraphs, links, emphasis, code blocks.
- Remote images rendered in preview.
- GitHub-flavored Markdown tables (horizontally scrollable in compact snippet UI).
- In-app document editing and preview with local SwiftData storage.
- App Intents + snippet actions:
  - `Preview Markdown`
  - `Find Markdown Document`
  - `Copy as Rich Text`
  - `Open in MarkdownSnippet`

## Markdown Engine Choice

Markdown rendering uses [`swift-markdown-ui`](https://github.com/gonzalezreal/swift-markdown-ui), not `AttributedString(markdown:)`.

Why:

- Better Markdown fidelity for block layout (headings/paragraph spacing).
- GitHub-flavored Markdown support, including table parsing/rendering.
- Native SwiftUI theming/styling hooks for compact snippet constraints.
- Built on `swift-cmark` + GFM extensions.

## Tech Stack

- Swift 6
- SwiftUI
- SwiftData
- App Intents + SnippetIntent APIs
- XcodeGen
- `swift-markdown-ui` package dependency

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

## Install on iOS and iPadOS

Use this exact flow for iPhone and iPad:

1. Connect the device to your Mac (USB or trusted network pairing).
2. Run:
   ```bash
   xcodegen generate
   open MarkdownSnippet.xcodeproj
   ```
3. In Xcode, select target `MarkdownSnippet`.
4. Open **Signing & Capabilities**:
   - Set your Team.
   - If required, set a unique bundle ID (example: `com.yourname.MarkdownSnippet`).
5. Select your physical iPhone/iPad as the run destination.
6. Press `Cmd+R` to build and install.
7. On device, if prompted:
   - Enable Developer Mode in **Settings > Privacy & Security > Developer Mode**.
   - Trust the developer certificate in **Settings > General > VPN & Device Management**.
8. Launch the app once on-device so Shortcuts can index intents.

## How Snippet Actions Work

- `Copy Rich Text`:
  - Converts Markdown to attributed text.
  - Writes both `public.rtf` and UTF-8 plain text to pasteboard.
  - Intended for pasting styled text into rich-text destinations.
- `Open in App`:
  - Creates a new local document from snippet Markdown.
  - Uses the first non-empty line as title (leading `#` stripped), fallback `Imported Markdown`.
  - Opens the app (`openAppWhenRun = true`).

## Responsive Rendering Notes

Snippet previews use a compact renderer profile:

- Tightened heading and paragraph spacing for small windows.
- Tables wrapped in horizontal scroll containers.
- Table cells use compact typography/padding.
- Images constrained and rounded with subtle borders.
- Code blocks scroll horizontally when needed.

This keeps rendering usable in narrow iPhone snippet surfaces.

## Icon Asset Notes (Liquid Glass / Icon Composer)

- A PNG fallback app icon is included in `Assets.xcassets` for immediate builds.
- Research + workflow notes for `.icon` assets are in `ICON_COMPOSER_NOTES.md`.
- Recommended production path is to create/edit icons in Apple Icon Composer and import `.icon` into Xcode.

## Troubleshooting

- Intents not showing in Shortcuts:
  - Open the app once after install.
  - Reboot Shortcuts app.
  - Rebuild/reinstall from Xcode.
- Build issues after dependency changes:
  - Run `xcodegen generate`.
  - In Xcode: **Product > Clean Build Folder**.
- Signing failures:
  - Verify Team is selected.
  - Ensure bundle ID is unique for your account.
