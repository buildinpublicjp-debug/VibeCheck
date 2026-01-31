import SwiftUI
import Charts

struct WeightCard: View {
    let summaries: [DailySummary]

    private var todayWeight: Double? {
        summaries.first?.weightKg
    }

    private var chartData: [ChartDataPoint] {
        summaries.reversed().compactMap { summary in
            guard let weight = summary.weightKg else { return nil }
            return ChartDataPoint(date: summary.date, value: weight)
        }
    }

    var body: some View {
        HealthCard(
            title: "Weight",
            icon: "scalemass.fill",
            value: todayWeight.map { String(format: "%.1f", $0) } ?? "—",
            unit: "kg",
            tint: .green
        ) {
            if chartData.count > 1 {
                Chart(chartData) { point in
                    LineMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("kg", point.value)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("kg", point.value)
                    )
                    .foregroundStyle(.green.opacity(0.1))
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: .automatic(includesZero: false))
            } else {
                emptyChart
            }
        }
    }

    private var emptyChart: some View {
        Text("Not enough data")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
