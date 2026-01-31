import SwiftUI
import Charts

struct StepsCard: View {
    let summaries: [DailySummary]

    private var todaySteps: Int? {
        summaries.first?.steps
    }

    private var chartData: [ChartDataPoint] {
        summaries.reversed().compactMap { summary in
            guard let steps = summary.steps else { return nil }
            return ChartDataPoint(date: summary.date, value: Double(steps))
        }
    }

    var body: some View {
        HealthCard(
            title: "Steps",
            icon: "figure.walk",
            value: todaySteps.map { $0.formatted() } ?? "—",
            unit: "steps",
            tint: .orange
        ) {
            if chartData.count > 1 {
                Chart(chartData) { point in
                    BarMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Steps", point.value)
                    )
                    .foregroundStyle(.orange.gradient)
                    .cornerRadius(4)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
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
