
import SwiftUI

struct AIReportAnalysisView: View {
    let reportID: Int
    let reportTitle: String

    @State private var summary = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.purple)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("MedAI Analysis")
                            .font(.title2.bold())

                        Text(reportTitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Analyzing your report with MedAI...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)

                        Text(errorMessage)
                            .multilineTextAlignment(.center)

                        Button("Try Again") {
                            Task {
                                await analyzeReport()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()

                } else if !summary.isEmpty {
                    Text(summary)
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)

                } else {
                    Text("Preparing your report analysis...")
                        .foregroundStyle(.secondary)
                }

                Divider()

                Label(
                    "AI-generated explanations are informational only. Consult a qualified healthcare professional for medical interpretation.",
                    systemImage: "info.circle"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Report Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if summary.isEmpty && errorMessage == nil {
                await analyzeReport()
            }
        }
    }

    @MainActor
    private func analyzeReport() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let response = try await AIReportService.shared
                .analyzeReport(id: reportID)

            summary = response.summary
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
