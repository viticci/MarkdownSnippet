import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MarkdownDocument.modifiedAt, order: .reverse) private var documents: [MarkdownDocument]

    var body: some View {
        NavigationStack {
            Group {
                if documents.isEmpty {
                    ContentUnavailableView {
                        Label("No Documents", systemImage: "doc.richtext")
                    } description: {
                        Text("Create a Markdown document or use the Preview Markdown shortcut.")
                    } actions: {
                        Button("New Document") {
                            createDocument()
                        }
                    }
                } else {
                    List {
                        ForEach(documents) { doc in
                            NavigationLink(destination: MarkdownEditorView(document: doc)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(doc.title)
                                        .font(.headline)

                                    Text(doc.content.prefix(80))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)

                                    Text(doc.modifiedAt, style: .relative)
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: createDocument) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func createDocument() {
        let doc = MarkdownDocument(
            title: "New Document",
            content: "# Hello\n\nStart writing **Markdown** here."
        )
        modelContext.insert(doc)
    }

    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(documents[index])
        }
    }
}
