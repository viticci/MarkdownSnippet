import SwiftUI
import SwiftData

struct MarkdownEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var document: MarkdownDocument
    
    @State private var showPreview = false
    @State private var attributedPreview: AttributedString?
    
    var body: some View {
        VStack(spacing: 0) {
            if showPreview {
                // Split view with editor and preview
                HStack(spacing: 0) {
                    // Editor
                    editorView
                        .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    // Preview
                    previewView
                        .frame(maxWidth: .infinity)
                }
            } else {
                // Full editor
                editorView
            }
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showPreview.toggle()
                } label: {
                    Label(
                        showPreview ? "Hide Preview" : "Show Preview",
                        systemImage: showPreview ? "eye.slash" : "eye"
                    )
                }
            }
        }
        .onChange(of: document.content) { _, _ in
            document.modifiedAt = Date()
            updatePreview()
        }
        .task {
            updatePreview()
        }
    }
    
    private var editorView: some View {
        VStack(spacing: 0) {
            // Title editor
            TextField("Title", text: $document.title)
                .font(.title2.bold())
                .padding()
                .background(Color(.systemBackground))
            
            Divider()
            
            // Content editor
            TextEditor(text: $document.content)
                .font(.body.monospaced())
                .padding()
        }
    }
    
    private var previewView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let attributed = attributedPreview {
                    Text(attributed)
                        .textSelection(.enabled)
                } else {
                    Text("Invalid markdown")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(Color(.secondarySystemBackground))
    }
    
    private func updatePreview() {
        Task {
            let options = AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .full
            )
            attributedPreview = try? AttributedString(
                markdown: document.content,
                options: options
            )
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MarkdownDocument.self, configurations: config)
    let document = MarkdownDocument(
        title: "Sample Document",
        content: """
        # Heading
        
        This is **bold** and *italic*.
        
        - List item
        - Another item
        """
    )
    container.mainContext.insert(document)
    
    return NavigationStack {
        MarkdownEditorView(document: document)
    }
    .modelContainer(container)
}
