import SwiftUI

struct HobbiesView: View {
    @State var viewModel: HobbiesViewModel
    @State private var showingAddHobby = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("For the evening commute")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                            Text("Hobbies").font(.largeTitle.bold()).foregroundStyle(Theme.textPrimary)
                        }
                        Spacer()
                        Button { showingAddHobby = true } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(Theme.textPrimary, in: Circle())
                        }
                    }

                    if let pick = viewModel.tonightsPick {
                        tonightsPickCard(pick)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("All hobbies").font(.headline).foregroundStyle(Theme.textPrimary)

                        ForEach(viewModel.hobbies) { hobby in
                            HobbyRow(hobby: hobby) {
                                viewModel.logToday(hobby)
                            }
                        }

                        Button {
                            showingAddHobby = true
                        } label: {
                            Label("Add a hobby", systemImage: "plus")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                        }
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.cardBorder, style: StrokeStyle(lineWidth: 1, dash: [5])))
                    }
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddHobby) {
                AddHobbyView(viewModel: viewModel)
            }
        }
        .task { viewModel.load() }
    }

    private func tonightsPickCard(_ hobby: Hobby) -> some View {
        HStack(spacing: 12) {
            Text("\u{1F3A8}").font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text("Tonight's pick").font(.caption.weight(.bold)).foregroundStyle(Color(hex: "B8563F"))
                Text(hobby.name).font(.headline).foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            Button("Log it") { viewModel.logToday(hobby) }
                .font(.caption.weight(.bold))
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
        }
        .card(fill: Theme.warnSoft, border: Theme.warnBorder, radius: 18)
    }
}

private struct HobbyRow: View {
    let hobby: Hobby
    let onLog: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(hobby.name).font(.subheadline.weight(.bold)).foregroundStyle(Theme.textPrimary)
                    if hobby.commuteFriendly {
                        Text("BART-friendly")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Theme.accentSoft, in: Capsule())
                            .foregroundStyle(Color(hex: "B8563F"))
                    }
                }
                Text(subtitle).font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Button("Log", action: onLog)
                .font(.caption.weight(.bold))
                .buttonStyle(.bordered)
                .tint(Theme.accent)
        }
        .card()
    }

    private var subtitle: String {
        let statusLabel = hobby.status.displayName
        if let last = hobby.lastLoggedAt {
            let days = Calendar.current.dateComponents([.day], from: last, to: .now).day ?? 0
            return "\(statusLabel) - last done \(days == 0 ? "today" : "\(days)d ago")"
        }
        return "\(statusLabel) - not logged yet"
    }
}
