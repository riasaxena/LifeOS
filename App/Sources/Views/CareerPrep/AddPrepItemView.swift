import SwiftUI

struct AddPrepItemView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: CareerPrepViewModel

    @State private var title = ""
    @State private var type: PrepItemType = .article
    @State private var url = ""
    @State private var topic = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    Picker("Type", selection: $type) {
                        ForEach(PrepItemType.allCases) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    TextField("Title", text: $title)
                    TextField("Topic (e.g. Interview Prep)", text: $topic)
                    TextField("Link (optional)", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Add to Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addItem(
                            title: title,
                            type: type,
                            url: url.isEmpty ? nil : url,
                            topic: topic.isEmpty ? "General" : topic
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
