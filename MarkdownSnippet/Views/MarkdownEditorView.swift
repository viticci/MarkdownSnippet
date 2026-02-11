import SwiftUI

struct MarkdownEditorView: View {
    @Bindable var document: MarkdownDocument

    @State private var showPreview = false

    var body: some View {
        VStack(spacing: 0) {
            TextField("Title", text: $document.title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 8)

            Divider()
                .padding(.vertical, 8)

            if showPreview {
                ScrollView {
                    MarkdownRenderView(markdown: document.content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            } else {
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
                Button {
                    showPreview.toggle()
                } label: {
                    Image(systemName: showPreview ? "pencil" : "eye")
                }
            }
        }
        .onChange(of: document.content) { _, _ in
            document.modifiedAt = Date()
        }
        .onChange(of: document.title) { _, _ in
            document.modifiedAt = Date()
        }
    }
}
