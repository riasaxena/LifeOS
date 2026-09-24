import SwiftUI

struct StreakDetailView: View {
    let viewModel: HealthViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\u{1F525}").font(.system(size: 44))
                    Text("\(viewModel.currentStreak) days")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Meds taken + a workout logged")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "B8563F"))
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .card(fill: Theme.warnSoft, border: Theme.warnBorder, radius: 22)

                HStack(spacing: 10) {
                    statTile(value: "\(viewModel.longestStreak)", label: "Longest streak")
                    statTile(value: "\(Int(viewModel.last30DayAdherence * 100))%", label: "Last 30 days")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Last 4 weeks").font(.headline).foregroundStyle(Theme.textPrimary)
                    VStack(spacing: 8) {
                        ForEach(Array(viewModel.last4Weeks.enumerated()), id: \.offset) { _, week in
                            HStack(spacing: 6) {
                                ForEach(Array(week.enumerated()), id: \.offset) { _, ok in
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(ok ? Theme.success : Theme.cardBorder)
                                        .frame(width: 26, height: 26)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .card()
                }
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle("Streak")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title3.weight(.heavy)).foregroundStyle(Theme.textPrimary)
            Text(label).font(.caption).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .card()
    }
}
