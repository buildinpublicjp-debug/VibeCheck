import SwiftUI
import Charts

struct SleepCard: View {
    let summaries: [DailySummary]

    private var todaySleep: Double? {
        summaries.first?.sleepHours
    }

    private var formattedSleep: String {
        guard let hours = todaySleep else { return "—" }
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }

    private var chartData: [ChartDataPoint] {
        summaries.reversed().compactMap { summary in
            guard let sleep = summary.sleepHours else { return nil }
            return ChartDataPoint(date: summary.date, value: sleep)
        }
    }

    var body: some View {
        HealthCard(
            title: "Sleep",
            icon: "bed.double.fill",
            value: formattedSleep,
            unit: "",
            tint: .indigo
        ) {
            if chartData.count > 1 {
                Chart(chartData) { point in
                    BarMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Hours", point.value)
                    )
                    .foregroundStyle(.indigo.gradient)
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
