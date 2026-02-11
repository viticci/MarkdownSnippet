# Icon Composer Notes (iOS 26 / Xcode 26)

## What I Researched

- Apple Icon Composer product page: https://developer.apple.com/icon-composer/
- Apple docs: https://developer.apple.com/documentation/Xcode/creating-your-app-icon-using-icon-composer
- Apple Developer Forums thread on `.icon` usage: https://developer.apple.com/forums/thread/813010

## Key Findings

- `.icon` is the new Icon Composer file type for layered Liquid Glass icons.
- Apple’s recommended path is to add the `.icon` file directly to the Xcode project.
- In target settings, `App Icon` must match the `.icon` filename (without extension).
- Apple documents the workflow, but not a stable public spec for hand-authoring the raw `.icon` file format.
- Practical implication: generate/edit `.icon` with Icon Composer, then import to Xcode instead of trying to manually craft binary contents.

## About Reverse-Engineering `Articles.icon`

I attempted to inspect:

`/Users/viticci/Library/Mobile Documents/com~apple~CloudDocs/* Temp Files/App Icons/Articles.icon`

but this process cannot access `~/Library/Mobile Documents` on this machine due macOS privacy restrictions for that directory.

## Practical Workflow For This Repo

1. Create/edit your Liquid Glass icon in Icon Composer.
2. Save as `AppIcon.icon` (or another chosen name).
3. Drag it into the Xcode project navigator under the app target.
4. In target `General > App Icons and Launch Screen`, set `App Icon` to the `.icon` name without extension.
5. Build and run on iOS/iPadOS 26 to verify dynamic rendering modes.

## Current Repo Status

- Added a generated 1024 PNG fallback icon at:
  - `MarkdownSnippet/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
- Updated:
  - `MarkdownSnippet/Assets.xcassets/AppIcon.appiconset/Contents.json`

This keeps the app icon valid immediately while still supporting migration to a true Icon Composer `.icon` asset in Xcode 26.
