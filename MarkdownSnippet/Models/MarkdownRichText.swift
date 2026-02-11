import Foundation
import UIKit

struct MarkdownRichText {
    static func attributedString(
        from markdown: String,
        baseFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        includeLinks: Bool = true
    ) -> AttributedString? {
        let sanitized = markdown.sanitizedMarkdownInput()
        guard let attributed = parsedAttributedMarkdown(from: sanitized) else {
            return nil
        }

        return applyPresentationIntents(to: attributed, baseFont: baseFont, includeLinks: includeLinks)
    }

    static func nsAttributedString(
        from markdown: String,
        baseFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        includeLinks: Bool = true
    ) -> NSAttributedString? {
        guard let attributed = attributedString(
            from: markdown,
            baseFont: baseFont,
            includeLinks: includeLinks
        ) else {
            return nil
        }

        return NSAttributedString(attributed)
    }
    
    static func plainText(from markdown: String) -> String {
        let sanitized = markdown.sanitizedMarkdownInput().replacingOccurrences(of: "\r\n", with: "\n")
        let lines = sanitized.split(separator: "\n", omittingEmptySubsequences: false)

        return lines.map { line in
            let source = String(line)
            guard !source.isEmpty else {
                return ""
            }

            if let parsed = try? AttributedString(
                markdown: source,
                options: .init(interpretedSyntax: .full)
            ) {
                let output = String(parsed.characters)
                return output.isEmpty ? source : output
            }

            if let parsed = try? AttributedString(
                markdown: source,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            ) {
                let output = String(parsed.characters)
                return output.isEmpty ? source : output
            }

            return source
        }
        .joined(separator: "\n")
    }

    private static func parsedAttributedMarkdown(from markdown: String) -> AttributedString? {
        if let full = try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .full)
        ) {
            return full
        }

        return try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
    }

    private static func applyPresentationIntents(
        to attributed: AttributedString,
        baseFont: UIFont,
        includeLinks: Bool
    ) -> AttributedString {
        var resolved = AttributedString()
        var previousBlockIdentity: Int?

        for run in attributed.runs {
            let blockIdentity = run.presentationIntent?.components.first?.identity
            if let previousBlockIdentity, let blockIdentity, previousBlockIdentity != blockIdentity {
                resolved += AttributedString("\n\n")
            }

            var segmentText = String(attributed[run.range].characters)

            if let inlineIntent = run.inlinePresentationIntent,
               inlineIntent.contains(.softBreak) || inlineIntent.contains(.lineBreak)
            {
                segmentText = "\n"
            }

            guard !segmentText.isEmpty else {
                previousBlockIdentity = blockIdentity ?? previousBlockIdentity
                continue
            }

            var segment = AttributedString(segmentText)
            segment.font = font(
                for: run,
                baseFont: baseFont
            )

            if includeLinks, let link = run.link {
                segment.link = link
            }

            resolved += segment
            previousBlockIdentity = blockIdentity ?? previousBlockIdentity
        }

        return resolved
    }

    private static func font(
        for run: AttributedString.Runs.Run,
        baseFont: UIFont
    ) -> UIFont {
        var font = baseFont

        if let presentationKind = run.presentationIntent?.components.first?.kind {
            switch presentationKind {
            case .header(let level):
                let sizeScale: CGFloat
                switch level {
                case 1: sizeScale = 1.7
                case 2: sizeScale = 1.5
                case 3: sizeScale = 1.3
                case 4: sizeScale = 1.15
                default: sizeScale = 1.0
                }
                font = UIFont.systemFont(ofSize: baseFont.pointSize * sizeScale, weight: .semibold)
            default:
                break
            }
        }

        if let inlineIntent = run.inlinePresentationIntent {
            if inlineIntent.contains(.code) {
                let design = font.fontDescriptor.withDesign(.monospaced)
                if let design {
                    font = UIFont(descriptor: design, size: font.pointSize)
                } else {
                    font = UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
                }
            }

            var traits = font.fontDescriptor.symbolicTraits
            if inlineIntent.contains(.emphasized) {
                traits.insert(.traitItalic)
            }
            if inlineIntent.contains(.stronglyEmphasized) {
                traits.insert(.traitBold)
            }

            if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                font = UIFont(descriptor: descriptor, size: font.pointSize)
            }
        }

        return font
    }
}
