import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    ForEach(TaskSection.allCases, id: \.self) { section in
                        let items = viewModel.tasks.filter { $0.section == section }
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.rawValue.uppercased())
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Theme.textMuted)

                                ForEach(items) { item in
                                    TaskRow(item: item) {
                                        viewModel.complete(item)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationBarHidden(true)
        }
        .task { viewModel.load() }
        .refreshable { viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.textPrimary)

            HStack {
                Text("\(viewModel.doneCount) of \(viewModel.totalCount) done today")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\u{1F525} \(viewModel.currentStreak)-day streak")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.success)
            }

            ProgressView(value: viewModel.totalCount == 0 ? 0 : Double(viewModel.doneCount) / Double(viewModel.totalCount))
                .tint(Theme.success)
        }
    }
}

private struct TaskRow: View {
    let item: TaskItem
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onComplete) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isDone ? Theme.success : Theme.accent)
            }
            .buttonStyle(.plain)
            .disabled(item.isDone || item.action == nil)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .strikethrough(item.isDone)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .opacity(item.isDone ? 0.55 : 1)
        .card()
    }
}
