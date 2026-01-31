import SwiftUI

struct EntryCard: View {
    let entry: ParsedEntry

    private var category: EntryCategory? {
        entry.category
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category?.systemImage ?? "questionmark")
                .font(.body)
                .foregroundStyle(category?.tintColor ?? .secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(category?.displayName ?? entry.categoryRawValue.capitalized)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(category?.tintColor ?? .secondary)

                Text(entry.content)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
