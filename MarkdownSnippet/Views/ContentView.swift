import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MarkdownDocument.modifiedAt, order: .reverse)
    private var documents: [MarkdownDocument]

    @State private var selectedDocument: MarkdownDocument?
    @State private var showingNewDoc = false

    var body: some View {
        NavigationStack {
            Group {
                if documents.isEmpty {
                    ContentUnavailableView {
                        Label("No Documents", systemImage: "doc.richtext")
                    } description: {
                        Text("Tap the + button to create your first Markdown document.")
                    }
                } else {
                    List {
                        ForEach(documents) { document in
                            NavigationLink(value: document) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(document.title)
                                        .font(.headline)
                                    Text(document.preview)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                    Text(document.modifiedAt, style: .relative)
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteDocuments)
                    }
                }
            }
            .navigationTitle("MarkdownSnippet")
            .navigationDestination(for: MarkdownDocument.self) { document in
                MarkdownEditorView(document: document)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createDocument()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func createDocument() {
        let doc = MarkdownDocument(
            title: "New Document",
            content: "# Hello, Markdown!\n\nStart writing here..."
        )
        modelContext.insert(doc)
        try? modelContext.save()
    }

    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(documents[index])
        }
        try? modelContext.save()
    }
}
