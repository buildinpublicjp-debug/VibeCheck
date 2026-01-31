import SwiftUI
import Charts

struct HeartRateCard: View {
    let summaries: [DailySummary]

    private var todayHR: Int? {
        summaries.first?.restingHeartRate
    }

    private var chartData: [ChartDataPoint] {
        summaries.reversed().compactMap { summary in
            guard let hr = summary.restingHeartRate else { return nil }
            return ChartDataPoint(date: summary.date, value: Double(hr))
        }
    }

    var body: some View {
        HealthCard(
            title: "Resting HR",
            icon: "heart.fill",
            value: todayHR.map { "\($0)" } ?? "—",
            unit: "bpm",
            tint: .red
        ) {
            if chartData.count > 1 {
                Chart(chartData) { point in
                    LineMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("bpm", point.value)
                    )
                    .foregroundStyle(.red)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("bpm", point.value)
                    )
                    .foregroundStyle(.red.opacity(0.1))
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
