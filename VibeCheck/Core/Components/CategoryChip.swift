import SwiftUI

struct CategoryChip: View {
    let category: EntryCategory?
    let isSelected: Bool
    let action: () -> Void

    private var label: String {
        category?.displayName ?? "All"
    }

    private var icon: String {
        category?.systemImage ?? "tray.full"
    }

    private var tint: Color {
        category?.tintColor ?? .accentColor
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(label)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? tint.opacity(0.2) : Color(.tertiarySystemFill))
            .foregroundStyle(isSelected ? tint : .secondary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
