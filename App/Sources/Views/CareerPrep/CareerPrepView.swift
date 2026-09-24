import SwiftUI

struct CareerPrepView: View {
    @State var viewModel: CareerPrepViewModel
    @State private var showingAddItem = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("For the morning commute")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                            Text("Career Prep").font(.largeTitle.bold()).foregroundStyle(Theme.textPrimary)
                        }
                        Spacer()
                        Button { showingAddItem = true } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(Theme.textPrimary, in: Circle())
                        }
                    }

                    if let upNext = viewModel.upNext {
                        upNextCard(upNext)
                    }

                    if !viewModel.restOfQueue.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Up after that").font(.headline).foregroundStyle(Theme.textPrimary)
                            ForEach(viewModel.restOfQueue) { item in
                                PrepItemRow(item: item) {
                                    viewModel.markDone(item)
                                }
                            }
                        }
                    }

                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add an article or podcast", systemImage: "plus")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.cardBorder, style: StrokeStyle(lineWidth: 1, dash: [5])))

                    if !viewModel.recentlyCompleted.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recently completed").font(.headline).foregroundStyle(Theme.textPrimary)
                            ForEach(viewModel.recentlyCompleted) { item in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.success)
                                    Text(item.title).font(.caption.weight(.semibold)).foregroundStyle(Theme.textSecondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddItem) {
                AddPrepItemView(viewModel: viewModel)
            }
        }
        .task { viewModel.load() }
    }

    private func upNextCard(_ item: PrepItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(item.type == .podcast ? "\u{1F3A7}" : "\u{1F4F0}")
                Text("Up next").font(.caption.weight(.bold)).foregroundStyle(Color(hex: "B8563F"))
            }
            Text(item.title).font(.headline).foregroundStyle(Theme.textPrimary)
            Text(item.topic).font(.caption).foregroundStyle(Theme.textSecondary)
            Button("Mark done") { viewModel.markDone(item) }
                .font(.caption.weight(.bold))
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(fill: Theme.warnSoft, border: Theme.warnBorder, radius: 18)
    }
}

private struct PrepItemRow: View {
    let item: PrepItem
    let onDone: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(item.type == .podcast ? "\u{1F3A7}" : "\u{1F4F0}")
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.textPrimary)
                Text(item.topic).font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Button("Done", action: onDone)
                .font(.caption.weight(.bold))
                .buttonStyle(.bordered)
                .tint(Theme.accent)
        }
        .card()
    }
}
