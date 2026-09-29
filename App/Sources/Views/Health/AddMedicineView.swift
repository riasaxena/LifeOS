import SwiftUI

struct AddMedicineView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: HealthViewModel

    @State private var name = ""
    @State private var dosage = ""
    /// ISO weekdays (1 = Monday ... 7 = Sunday), matching Medicine.scheduleDays.
    @State private var scheduleDays: Set<Int> = Set(1...7)

    private let weekdayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Medicine") {
                    TextField("Name", text: $name)
                    TextField("Dosage (optional)", text: $dosage)
                }

                Section("Take it on") {
                    HStack(spacing: 6) {
                        ForEach(1...7, id: \.self) { day in
                            let isOn = scheduleDays.contains(day)
                            Button {
                                if isOn { scheduleDays.remove(day) } else { scheduleDays.insert(day) }
                            } label: {
                                Text(weekdayLabels[day - 1])
                                    .font(.subheadline.weight(.bold))
                                    .frame(maxWidth: .infinity, minHeight: 36)
                                    .background(isOn ? Theme.accent : Theme.accentSoft, in: Circle())
                                    .foregroundStyle(isOn ? .white : Color(hex: "B8563F"))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Add Medicine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addMedicine(
                            name: name,
                            dosage: dosage.isEmpty ? nil : dosage,
                            scheduleDays: scheduleDays.sorted()
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || scheduleDays.isEmpty)
                }
            }
        }
    }
}
