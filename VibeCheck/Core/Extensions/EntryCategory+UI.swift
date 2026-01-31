import SwiftUI

extension EntryCategory {
    var tintColor: Color {
        switch self {
        case .workout: .orange
        case .reading: .blue
        case .insight: .purple
        case .work: .gray
        case .food: .green
        case .health: .red
        }
    }
}
