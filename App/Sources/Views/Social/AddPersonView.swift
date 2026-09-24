import SwiftUI

struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: SocialViewModel

    @State private var name = ""
    @State private var category: ContactCategory = .friend
    @State private var preferredMedium: ContactMedium = .call
    @State private var cadenceDays = 14
    @State private var note = ""

    private let cadenceOptions = [7, 14, 30]

    var body: some View {
        NavigationStack {
            Form {
                Section("Who") {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        Text("Friend").tag(ContactCategory.friend)
                        Text("Work").tag(ContactCategory.work)
                    }
                    .pickerStyle(.segmented)
                }

                Section("How you'll stay in touch") {
                    Picker("Preferred method", selection: $preferredMedium) {
                        Text("Call").tag(ContactMedium.call)
                        Text("Email").tag(ContactMedium.email)
                    }
                    .pickerStyle(.segmented)

                    Picker("Check in every", selection: $cadenceDays) {
                        ForEach(cadenceOptions, id: \.self) { days in
                            Text(cadenceLabel(days)).tag(days)
                        }
                    }
                }

                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addPerson(
                            name: name,
                            category: category,
                            preferredMedium: preferredMedium,
                            cadenceDays: cadenceDays,
                            note: note.isEmpty ? nil : note
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func cadenceLabel(_ days: Int) -> String {
        switch days {
        case 7: return "Weekly"
        case 14: return "Every 2 weeks"
        case 30: return "Monthly"
        default: return "\(days) days"
        }
    }
}
