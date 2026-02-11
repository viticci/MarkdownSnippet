import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MarkdownDocument.modifiedAt, order: .reverse) private var documents: [MarkdownDocument]
    
    @State private var showingEditor = false
    @State private var selectedDocument: MarkdownDocument?
    
    var body: some View {
        NavigationStack {
            Group {
                if documents.isEmpty {
                    ContentUnavailableView(
                        "No Documents",
                        systemImage: "doc.text",
                        description: Text("Create a new markdown document to get started")
                    )
                } else {
                    List {
                        ForEach(documents) { document in
                            NavigationLink(destination: MarkdownEditorView(document: document)) {
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
            .navigationTitle("Markdown Snippets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createNewDocument()
                    } label: {
                        Label("New Document", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func createNewDocument() {
        let document = MarkdownDocument(
            title: "Untitled",
            content: "# New Document\n\nStart writing your markdown here..."
        )
        modelContext.insert(document)
        try? modelContext.save()
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            let document = documents[index]
            modelContext.delete(document)
        }
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MarkdownDocument.self, inMemory: true)
}
