import SwiftUI

struct SocialView: View {
    @State var viewModel: SocialViewModel
    @State private var showingAddPerson = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Who to catch up with")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)
                        Text("Social").font(.largeTitle.bold()).foregroundStyle(Theme.textPrimary)
                    }
                    Spacer()
                    Button { showingAddPerson = true } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Theme.textPrimary, in: Circle())
                    }
                }

                Picker("Category", selection: $viewModel.selectedCategory) {
                    Text("Friends").tag(ContactCategory.friend)
                    Text("Work").tag(ContactCategory.work)
                }
                .pickerStyle(.segmented)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.visibleContacts) { contact in
                            ContactRow(contact: contact) {
                                viewModel.logCall(contact)
                            }
                        }

                        Button {
                            showingAddPerson = true
                        } label: {
                            Label("Add someone to the list", systemImage: "plus")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                        }
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.cardBorder, style: StrokeStyle(lineWidth: 1, dash: [5])))
                    }
                }
            }
            .padding(20)
            .background(Theme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddPerson) {
                AddPersonView(viewModel: viewModel)
            }
        }
        .task { viewModel.load() }
    }
}

private struct ContactRow: View {
    let contact: Contact
    let onLogCall: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Theme.accentSoft)
                    Text(initials)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(hex: "B8563F"))
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name).font(.subheadline.weight(.bold)).foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(contact.isOverdue ? Color(hex: "B8563F") : Theme.textSecondary)
                }
                Spacer()
            }
            if contact.isOverdue {
                Button("Log a call", action: onLogCall)
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(11)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
        }
        .card(radius: 18)
    }

    private var initials: String {
        contact.name.split(separator: " ").compactMap(\.first).map(String.init).joined()
    }

    private var subtitle: String {
        if let days = contact.daysSinceContact {
            return contact.isOverdue ? "Overdue - last talked \(days) days ago" : "Every \(contact.cadenceDays) days - \(days) days ago"
        }
        return "Never contacted yet"
    }
}
