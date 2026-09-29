import SwiftUI

struct HealthView: View {
    @State var viewModel: HealthViewModel
    @State private var showingAddMedicine = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        Text("Health")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Button { showingAddMedicine = true } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(Theme.textPrimary, in: Circle())
                        }
                    }

                    NavigationLink {
                        StreakDetailView(viewModel: viewModel)
                    } label: {
                        streakBanner
                    }
                    .buttonStyle(.plain)

                    medicineSection
                    workoutSection
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddMedicine) {
                AddMedicineView(viewModel: viewModel)
            }
        }
        .task { viewModel.load() }
    }

    private var streakBanner: some View {
        HStack(spacing: 12) {
            Text("\u{1F525}").font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.currentStreak)-day streak")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text("Meds + a workout, every day this streak")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "B8563F"))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color(hex: "B8563F"))
        }
        .card(fill: Theme.warnSoft, border: Theme.warnBorder, radius: 18)
    }

    private var medicineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Medicine").font(.headline).foregroundStyle(Theme.textPrimary)
            ForEach(viewModel.medicines) { medicine in
                medicineRow(medicine, log: viewModel.todaysLog(for: medicine))
                    .contextMenu {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteMedicine(medicine)
                        }
                    }
            }

            Button {
                showingAddMedicine = true
            } label: {
                Label("Add a medicine", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(14)
            }
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.cardBorder, style: StrokeStyle(lineWidth: 1, dash: [5])))
        }
    }

    /// `log` is nil when the medicine isn't scheduled for today.
    private func medicineRow(_ medicine: Medicine, log: MedicineLog?) -> some View {
        let isTaken = log?.isTaken == true
        let isDue = log != nil && !isTaken
        let status = log == nil ? "Not due today" : (isTaken ? "Taken" : "Not yet taken")
        return HStack(spacing: 12) {
            Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isTaken ? Theme.success : (isDue ? Theme.accent : Theme.textSecondary))
            VStack(alignment: .leading, spacing: 1) {
                Text(medicine.name).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.textPrimary)
                Text([status, medicine.dosage].compactMap { $0 }.joined(separator: " - "))
                    .font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if isDue {
                Button("Mark taken") { viewModel.markTaken(medicine) }
                    .font(.caption.weight(.bold))
                    .buttonStyle(.bordered)
                    .tint(Theme.accent)
            }
        }
        .card(fill: isDue ? Theme.warnSoft : Theme.card, border: isDue ? Theme.warnBorder : Theme.cardBorder)
    }

    private var workoutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's workout").font(.headline).foregroundStyle(Theme.textPrimary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WorkoutType.allCases) { type in
                    let isSelected = viewModel.todaysWorkout?.type == type
                    Button {
                        viewModel.logWorkout(type)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.emoji).font(.title3)
                            Text(type.displayName)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(isSelected ? .white : Theme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(isSelected ? Theme.textPrimary : Theme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: isSelected ? 0 : 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
