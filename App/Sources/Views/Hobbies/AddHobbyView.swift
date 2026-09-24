import SwiftUI

struct AddHobbyView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: HobbiesViewModel

    @State private var name = ""
    @State private var status: HobbyStatus = .wantToTry
    @State private var commuteFriendly = false
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Hobby") {
                    TextField("Name", text: $name)
                    Picker("Status", selection: $status) {
                        ForEach(HobbyStatus.allCases) { s in
                            Text(s.displayName).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Good for the BART commute", isOn: $commuteFriendly)
                }

                Section("Notes") {
                    TextField("Optional note", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add Hobby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addHobby(
                            name: name,
                            status: status,
                            commuteFriendly: commuteFriendly,
                            notes: notes.isEmpty ? nil : notes
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
