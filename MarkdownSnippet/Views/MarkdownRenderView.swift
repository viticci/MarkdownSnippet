import SwiftUI
import MarkdownUI

struct MarkdownRenderView: View {
    let markdown: String
    var compact: Bool = false
    var transparentTextBackground: Bool = false

    private var sanitizedMarkdown: String {
        markdown.sanitizedMarkdownInput()
    }
    
    private var activeTheme: Theme {
        if transparentTextBackground {
            return Theme.gitHub.text {
                ForegroundColor(Color.primary)
                BackgroundColor(nil)
                FontSize(16)
            }
        }
        
        return .gitHub
    }

    var body: some View {
        Group {
            if compact {
                CompactMarkdownTextView(markdown: sanitizedMarkdown)
            } else {
                Markdown(sanitizedMarkdown)
                    .markdownTheme(activeTheme)
                    .markdownImageProvider(.default)
                    .markdownSoftBreakMode(.lineBreak)
                    .markdownBlockStyle(\.heading1) { configuration in
                        configuration.label
                            .markdownTextStyle {
                                FontWeight(.semibold)
                                FontSize(.em(compact ? 1.4 : 1.9))
                            }
                            .markdownMargin(top: compact ? 12 : 24, bottom: compact ? 8 : 14)
                    }
                    .markdownBlockStyle(\.heading2) { configuration in
                        configuration.label
                            .markdownTextStyle {
                                FontWeight(.semibold)
                                FontSize(.em(compact ? 1.25 : 1.5))
                            }
                            .markdownMargin(top: compact ? 10 : 22, bottom: compact ? 8 : 14)
                    }
                    .markdownBlockStyle(\.heading3) { configuration in
                        configuration.label
                            .markdownTextStyle {
                                FontWeight(.semibold)
                                FontSize(.em(compact ? 1.1 : 1.25))
                            }
                            .markdownMargin(top: compact ? 8 : 20, bottom: compact ? 6 : 12)
                    }
                    .markdownBlockStyle(\.paragraph) { configuration in
                        configuration.label
                            .fixedSize(horizontal: false, vertical: true)
                            .relativeLineSpacing(.em(compact ? 0.2 : 0.25))
                            .markdownMargin(top: 0, bottom: compact ? 10 : 14)
                    }
                    .markdownBlockStyle(\.codeBlock) { configuration in
                        ScrollView(.horizontal, showsIndicators: false) {
                            configuration.label
                                .fixedSize(horizontal: false, vertical: true)
                                .relativeLineSpacing(.em(0.2))
                                .padding(compact ? 10 : 14)
                        }
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous))
                        .markdownMargin(top: 0, bottom: compact ? 10 : 14)
                    }
                    .markdownBlockStyle(\.image) { configuration in
                        configuration.label
                            .frame(maxWidth: compact ? 280 : .infinity, alignment: .leading)
                            .clipShape(RoundedRectangle(cornerRadius: compact ? 10 : 12, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: compact ? 10 : 12, style: .continuous)
                                    .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1)
                            }
                            .markdownMargin(top: 0, bottom: compact ? 10 : 14)
                    }
                    .markdownBlockStyle(\.table) { configuration in
                        ScrollView(.horizontal, showsIndicators: false) {
                            configuration.label
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .markdownTableBorderStyle(.init(color: Color(uiColor: .separator)))
                        .markdownTableBackgroundStyle(
                            .alternatingRows(
                                .clear,
                                Color(uiColor: .secondarySystemBackground).opacity(0.65)
                            )
                        )
                        .markdownMargin(top: 0, bottom: compact ? 10 : 14)
                    }
                    .markdownBlockStyle(\.tableCell) { configuration in
                        configuration.label
                            .markdownTextStyle {
                                if configuration.row == 0 {
                                    FontWeight(.semibold)
                                }
                                FontSize(.em(compact ? 0.85 : 0.95))
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .relativeLineSpacing(.em(0.2))
                            .padding(.vertical, compact ? 4 : 6)
                            .padding(.horizontal, compact ? 8 : 12)
                    }
            }
        }
    }
}

private struct CompactMarkdownTextView: View {
    let markdown: String

    var body: some View {
        Text(markdown.sanitizedMarkdownInput())
            .font(.body)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
