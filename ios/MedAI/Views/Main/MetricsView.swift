
import SwiftUI

struct MetricsView: View {
    @State private var metrics: [HealthMetric] = []
    @State private var selectedFilter = "All"
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let filters = ["All", "Week", "Month", "Year"]

    // MARK: - Filtered Metrics

    private var filteredMetrics: [HealthMetric] {
        guard selectedFilter != "All" else {
            return metrics
        }

        let calendar = Calendar.current
        let now = Date()

        return metrics.filter { metric in
            guard let date = parseDate(metric.recorded_at),
                  date <= now else {
                return false
            }

            switch selectedFilter {
            case "Week":
                guard let startDate = calendar.date(
                    byAdding: .day,
                    value: -7,
                    to: now
                ) else {
                    return false
                }
                return date >= startDate

            case "Month":
                guard let startDate = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: now
                ) else {
                    return false
                }
                return date >= startDate

            case "Year":
                guard let startDate = calendar.date(
                    byAdding: .year,
                    value: -1,
                    to: now
                ) else {
                    return false
                }
                return date >= startDate

            default:
                return true
            }
        }
    }

    // MARK: - Main View

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                if isLoading && metrics.isEmpty {
                    Spacer()
                    ProgressView("Loading health metrics...")
                    Spacer()

                } else if let errorMessage = errorMessage,
                          metrics.isEmpty {
                    Spacer()

                    ContentUnavailableView {
                        Label(
                            "Unable to Load Metrics",
                            systemImage: "exclamationmark.triangle"
                        )
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try Again") {
                            Task {
                                await loadMetrics()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Spacer()

                } else if filteredMetrics.isEmpty {
                    Spacer()

                    ContentUnavailableView(
                        "No Health Metrics",
                        systemImage: "heart.text.square",
                        description: Text(
                            selectedFilter == "All"
                                ? "Your health metrics will appear here."
                                : "No metrics found for this period."
                        )
                    )

                    Spacer()

                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredMetrics) { metric in
                                metricRow(metric)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await loadMetrics()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Health Metrics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await loadMetrics()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.blue)
                    }
                    .disabled(isLoading)
                    .accessibilityLabel("Refresh metrics")
                }
            }
            .task {
                await loadMetrics()
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: 4) {
            ForEach(filters, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter)
                        .font(.subheadline)
                        .fontWeight(
                            selectedFilter == filter
                                ? .semibold
                                : .regular
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .foregroundStyle(
                            selectedFilter == filter
                                ? Color.white
                                : Color.primary
                        )
                        .background {
                            if selectedFilter == filter {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color.blue)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Metric Row

    private func metricRow(_ metric: HealthMetric) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        metricColor(metric.metric_type)
                            .opacity(0.12)
                    )
                    .frame(width: 46, height: 46)

                Image(systemName: metricIcon(metric.metric_type))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(metricColor(metric.metric_type))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(displayName(metric.metric_type))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(
                        metric.value.formatted(
                            .number.precision(.fractionLength(0...2))
                        )
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)

                    Text(metric.unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let date = parseDate(metric.recorded_at) {
                    Text(
                        date.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Display Names

    private func displayName(_ type: String) -> String {
        switch type.lowercased() {
        case "heart rate", "heart_rate":
            return "Heart Rate"
        case "spo2", "oxygen_saturation":
            return "SpO₂"
        case "steps", "step_count":
            return "Steps"
        case "sleep", "sleep_duration":
            return "Sleep"
        case "blood_pressure":
            return "Blood Pressure"
        case "temperature":
            return "Temperature"
        case "weight":
            return "Weight"
        case "blood_glucose":
            return "Blood Glucose"
        default:
            return type
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
        }
    }

    // MARK: - Icons

    private func metricIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "heart rate", "heart_rate":
            return "heart.fill"
        case "spo2", "oxygen_saturation":
            return "lungs.fill"
        case "steps", "step_count":
            return "figure.walk"
        case "sleep", "sleep_duration":
            return "moon.zzz.fill"
        case "blood_pressure":
            return "heart.text.square.fill"
        case "temperature":
            return "thermometer.medium"
        case "weight":
            return "scalemass.fill"
        case "blood_glucose":
            return "drop.fill"
        default:
            return "waveform.path.ecg"
        }
    }

    // MARK: - Colors

    private func metricColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "heart rate", "heart_rate", "blood_pressure":
            return .red
        case "spo2", "oxygen_saturation":
            return .blue
        case "steps", "step_count":
            return .green
        case "sleep", "sleep_duration":
            return .purple
        case "temperature":
            return .cyan
        case "weight":
            return .orange
        case "blood_glucose":
            return .red
        default:
            return .blue
        }
    }

    // MARK: - Parse Backend Dates

    private func parseDate(_ value: String?) -> Date? {
        guard let value else {
            return nil
        }

        let trimmedValue = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // First try standard ISO 8601 with fractional seconds.
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = isoFormatter.date(from: trimmedValue) {
            return date
        }

        // Then try standard ISO 8601 without fractional seconds.
        isoFormatter.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter.date(from: trimmedValue) {
            return date
        }

        // Support backend timestamps such as:
        // 2026-10-12T08:19:48.484692
        // These timestamps have no timezone suffix.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        for format in formats {
            formatter.dateFormat = format

            if let date = formatter.date(from: trimmedValue) {
                return date
            }
        }

        return nil
    }

    // MARK: - Load Metrics

    @MainActor
    private func loadMetrics() async {
        isLoading = true
        errorMessage = nil

        do {
            metrics = try await HealthMetricService.shared.fetchMetrics()
        } catch {
            errorMessage = "Please check your connection and try again."
            print("Health metrics error: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    MetricsView()
}
