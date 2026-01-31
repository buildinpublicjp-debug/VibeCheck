import SwiftUI
import Charts

struct HealthCard<ChartContent: View>: View {
    let title: String
    let icon: String
    let value: String
    let unit: String
    let tint: Color
    @ViewBuilder let chart: () -> ChartContent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            chart()
                .frame(height: 60)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
