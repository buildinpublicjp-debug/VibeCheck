import Testing
import Foundation
@testable import VibeCheck

struct EntryCategoryTests {

    @Test func allCasesContainsSixCategories() {
        #expect(EntryCategory.allCases.count == 6)
    }

    @Test func rawValuesMatchExpected() {
        #expect(EntryCategory.workout.rawValue == "workout")
        #expect(EntryCategory.reading.rawValue == "reading")
        #expect(EntryCategory.insight.rawValue == "insight")
        #expect(EntryCategory.work.rawValue == "work")
        #expect(EntryCategory.food.rawValue == "food")
        #expect(EntryCategory.health.rawValue == "health")
    }

    @Test func displayNamesAreCapitalized() {
        #expect(EntryCategory.workout.displayName == "Workout")
        #expect(EntryCategory.reading.displayName == "Reading")
        #expect(EntryCategory.insight.displayName == "Insight")
        #expect(EntryCategory.work.displayName == "Work")
        #expect(EntryCategory.food.displayName == "Food")
        #expect(EntryCategory.health.displayName == "Health")
    }

    @Test func systemImagesAreNonEmpty() {
        for category in EntryCategory.allCases {
            #expect(!category.systemImage.isEmpty)
        }
    }
}
