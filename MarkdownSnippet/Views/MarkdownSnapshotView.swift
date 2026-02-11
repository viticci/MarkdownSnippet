import SwiftUI
import UIKit

struct MarkdownSnapshotView: View {
    let markdown: String

    @State private var image: UIImage?
    @State private var lastWidth: CGFloat = 0
    @State private var lastMarkdown: String = ""

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .topLeading) {
                if let image {
                    Image(uiImage: image)
                        .renderingMode(.original)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                renderImage(for: width)
            }
            .onChange(of: width) { _, newValue in
                renderImage(for: newValue)
            }
            .onChange(of: markdown) { _, _ in
                renderImage(for: width)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func renderImage(for width: CGFloat) {
        guard width > 0 else {
            return
        }

        if abs(width - lastWidth) < 0.5, image != nil, lastMarkdown == markdown {
            return
        }
        lastWidth = width
        lastMarkdown = markdown

        let sanitizedInput = markdown.sanitizedMarkdownInput()
        var attributed = MarkdownRichText.nsAttributedString(from: sanitizedInput, includeLinks: false) ?? NSAttributedString(string: sanitizedInput)

        let sanitizedOutput = attributed.string.sanitizedMarkdownInput()
        if sanitizedOutput != attributed.string {
            attributed = MarkdownRichText.nsAttributedString(from: sanitizedOutput, includeLinks: false) ?? NSAttributedString(string: sanitizedOutput)
        }

        let mutable = NSMutableAttributedString(attributedString: attributed)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        mutable.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutable.length))

        let bounding = mutable.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).integral
        let height = max(ceil(bounding.height), 1)
        let size = CGSize(width: width, height: height)

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let rendered = renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            mutable.draw(
                with: CGRect(origin: .zero, size: size),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
        }

        image = rendered
    }
}
