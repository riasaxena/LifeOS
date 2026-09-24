import SwiftUI
import SwiftData

/// Bundles the concrete (v1: SwiftData) repositories. Swapping to a future
/// cloud-backed set of repositories means changing only this struct - see
/// docs/HLD.md.
@MainActor
struct Repositories {
    let medicine: MedicineRepository
    let workout: WorkoutRepository
    let contact: ContactRepository
    let hobby: HobbyRepository
    let prepItem: PrepItemRepository

    init(context: ModelContext) {
        medicine = SwiftDataMedicineRepository(context: context)
        workout = SwiftDataWorkoutRepository(context: context)
        contact = SwiftDataContactRepository(context: context)
        hobby = SwiftDataHobbyRepository(context: context)
        prepItem = SwiftDataPrepItemRepository(context: context)
    }
}

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var repos: Repositories?

    var body: some View {
        Group {
            if let repos {
                TabView {
                    HealthView(viewModel: HealthViewModel(medicineRepo: repos.medicine, workoutRepo: repos.workout))
                        .tabItem { Label("Health", systemImage: "heart") }

                    SocialView(viewModel: SocialViewModel(repo: repos.contact))
                        .tabItem { Label("Social", systemImage: "person.2") }

                    HomeView(viewModel: HomeViewModel(
                        medicineRepo: repos.medicine,
                        workoutRepo: repos.workout,
                        contactRepo: repos.contact,
                        hobbyRepo: repos.hobby,
                        prepItemRepo: repos.prepItem
                    ))
                        .tabItem { Label("Home", systemImage: "house") }

                    HobbiesView(viewModel: HobbiesViewModel(repo: repos.hobby))
                        .tabItem { Label("Hobbies", systemImage: "paintpalette") }

                    CareerPrepView(viewModel: CareerPrepViewModel(repo: repos.prepItem))
                        .tabItem { Label("Career", systemImage: "book") }
                }
                .tint(Theme.accent)
            } else {
                ProgressView()
            }
        }
        .task {
            if repos == nil {
                repos = Repositories(context: modelContext)
            }
        }
    }
}
