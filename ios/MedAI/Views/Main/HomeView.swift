
import SwiftUI

struct HomeView: View {
    @State private var metrics: [HealthMetric] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Welcome
                    welcomeSection

                    // MARK: - Health Overview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Health Overview")
                            .font(.headline)
                            .fontWeight(.semibold)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            HealthCard(
                                icon: "heart.fill",
                                title: "Heart Rate",
                                value: metricValue(
                                    for: ["heart_rate", "heart rate", "heartrate"]
                                ),
                                unit: metricUnit(
                                    for: ["heart_rate", "heart rate", "heartrate"],
                                    fallback: "bpm"
                                )
                            )

                            HealthCard(
                                icon: "lungs.fill",
                                title: "SpO₂",
                                value: metricValue(
                                    for: ["spo2", "sp_o2", "oxygen_saturation", "oxygen saturation"]
                                ),
                                unit: metricUnit(
                                    for: ["spo2", "sp_o2", "oxygen_saturation", "oxygen saturation"],
                                    fallback: "%"
                                )
                            )

                            HealthCard(
                                icon: "figure.walk",
                                title: "Steps",
                                value: metricValue(
                                    for: ["steps", "step_count"]
                                ),
                                unit: metricUnit(
                                    for: ["steps", "step_count"],
                                    fallback: "steps"
                                )
                            )

                            HealthCard(
                                icon: "bed.double.fill",
                                title: "Sleep",
                                value: metricValue(
                                    for: ["sleep", "sleep_duration", "sleep_hours"]
                                ),
                                unit: metricUnit(
                                    for: ["sleep", "sleep_duration", "sleep_hours"],
                                    fallback: "hours"
                                )
                            )
                        }
                    }

                    // MARK: - Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)

                        HStack(spacing: 12) {
                            quickActionButton(
                                title: "Reports",
                                icon: "doc.text.fill",
                                tab: 2
                            )

                            quickActionButton(
                                title: "Medications",
                                icon: "pills.fill",
                                tab: 3
                            )

                            quickActionButton(
                                title: "Metrics",
                                icon: "chart.xyaxis.line",
                                tab: 1
                            )
                        }
                    }

                    // MARK: - MedAI Assistant
                    VStack(alignment: .leading, spacing: 12) {
                        Label(
                            "MedAI Assistant",
                            systemImage: "sparkles"
                        )
                        .font(.headline)
                        .foregroundStyle(.white)

                        Text(
                            "Ask questions about health and get " +
                            "AI-powered explanations."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))

                        NavigationLink {
                            MedAIChatView()
                        } label: {
                            Label(
                                "Ask MedAI",
                                systemImage: "arrow.right"
                            )
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.white)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [
                                .blue,
                                .cyan.opacity(0.85)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    // MARK: - Loading and Errors
                    if isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Loading health data...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let errorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)

                            Button("Retry") {
                                Task {
                                    await loadMetrics()
                                }
                            }
                            .font(.footnote.bold())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await loadMetrics()
            }
            .refreshable {
                await loadMetrics()
            }
        }
    }

    // MARK: - Welcome
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome to MedAI")
                .font(.title2)
                .fontWeight(.bold)

            Text("Your personal health companion")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Quick Action Button
    private func quickActionButton(
        title: String,
        icon: String,
        tab: Int
    ) -> some View {
        Button {
            NotificationCenter.default.post(
                name: Notification.Name("MedAINavigateToTab"),
                object: tab
            )
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Load Health Metrics
    @MainActor
    private func loadMetrics() async {
        isLoading = true
        errorMessage = nil

        do {
            try await HealthKitService.shared.syncToMedAI()
            print("✅ HealthKit sync completed")
        } catch {
            print("❌ HealthKit sync failed: \(error.localizedDescription)")
        }

        // Keep your existing health-metric API fetch here.

        isLoading = false
    }

    // MARK: - Normalize Metric Names
    private func normalized(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }

    // MARK: - Find Latest Matching Metric
    private func matchingMetric(
        for names: [String]
    ) -> HealthMetric? {
        let acceptedNames = Set(names.map(normalized))

        return metrics
            .filter {
                acceptedNames.contains(normalized($0.metric_type))
            }
            .max {
                ($0.recorded_at ?? "") < ($1.recorded_at ?? "")
            }
    }

    // MARK: - Display Metric Value
    private func metricValue(for names: [String]) -> String {
        guard let metric = matchingMetric(for: names) else {
            return "No data"
        }

        return metric.value.formatted(
            .number.precision(.fractionLength(0...2))
        )
    }

    // MARK: - Display Metric Unit
    private func metricUnit(
        for names: [String],
        fallback: String
    ) -> String {
        matchingMetric(for: names)?.unit ?? fallback
    }
}

#Preview {
    HomeView()
}
