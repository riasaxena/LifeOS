import Foundation
import SwiftData

/// Inserts a small set of sample data on first launch so the app isn't
/// empty out of the box - mirrors the mockups artifact linked from the
/// repo README. Safe to call every launch; it no-ops once anything exists.
@MainActor
enum SeedData {
    static func populateIfNeeded(context: ModelContext) {
        let existing = try? context.fetchCount(FetchDescriptor<Medicine>())
        guard existing == 0 else { return }

        let vitaminD = Medicine(name: "Vitamin D")
        let iron = Medicine(name: "Iron")
        context.insert(vitaminD)
        context.insert(iron)
        context.insert(MedicineLog(date: Calendar.current.startOfDay(for: .now), takenAt: .now, medicine: vitaminD))

        context.insert(Workout(date: Calendar.current.startOfDay(for: .now), type: .hotYoga))

        let maya = Contact(name: "Maya J.", category: .friend, preferredMedium: .call, cadenceDays: 14, lastContactedAt: Calendar.current.date(byAdding: .day, value: -35, to: .now))
        let devon = Contact(name: "Devon P.", category: .work, preferredMedium: .email, cadenceDays: 14, lastContactedAt: Calendar.current.date(byAdding: .day, value: -9, to: .now))
        let rina = Contact(name: "Rina K.", category: .friend, preferredMedium: .call, cadenceDays: 30, lastContactedAt: Calendar.current.date(byAdding: .day, value: -21, to: .now))
        [maya, devon, rina].forEach(context.insert)

        let sketching = Hobby(name: "Sketching", status: .active, commuteFriendly: true)
        let guitar = Hobby(name: "Guitar", status: .active, commuteFriendly: false)
        let japanese = Hobby(name: "Learn Japanese", status: .wantToTry, commuteFriendly: true)
        let embroidery = Hobby(name: "Embroidery", status: .wantToTry, commuteFriendly: false)
        [sketching, guitar, japanese, embroidery].forEach(context.insert)

        context.insert(PrepItem(title: "Behavioral Interviews: The STAR Method, Revisited", type: .article, topic: "Interview Prep"))
        context.insert(PrepItem(title: "Scaling Systems Design - Ep. 142", type: .podcast, topic: "Industry News"))
        context.insert(PrepItem(title: "Notes on Large-Scale Backend Migrations", type: .article, topic: "Technical"))

        try? context.save()
    }
}
