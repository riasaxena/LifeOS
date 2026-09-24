import SwiftUI

struct HealthView: View {
    @State var viewModel: HealthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Health")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.textPrimary)

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
            ForEach(viewModel.todaysLogs, id: \.id) { log in
                if let medicine = log.medicine {
                    HStack(spacing: 12) {
                        Image(systemName: log.isTaken ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(log.isTaken ? Theme.success : Theme.accent)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(medicine.name).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.textPrimary)
                            Text(log.isTaken ? "Taken" : "Not yet taken")
                                .font(.caption).foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        if !log.isTaken {
                            Button("Mark taken") { viewModel.markTaken(medicine) }
                                .font(.caption.weight(.bold))
                                .buttonStyle(.bordered)
                                .tint(Theme.accent)
                        }
                    }
                    .card(fill: log.isTaken ? Theme.card : Theme.warnSoft, border: log.isTaken ? Theme.cardBorder : Theme.warnBorder)
                }
            }
        }
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
