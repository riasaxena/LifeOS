import SwiftUI
import SwiftData

@main
struct LifeOSApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for:
                Medicine.self, MedicineLog.self,
                Workout.self,
                Contact.self, ContactLog.self,
                Hobby.self, HobbyLog.self,
                PrepItem.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        SeedData.populateIfNeeded(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
