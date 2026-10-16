
import SwiftUI
import UniformTypeIdentifiers

struct ReportsView: View {
    @State private var reports: [MedicalReport] = []
    @State private var isLoading = false
    @State private var isUploading = false
    @State private var showingFilePicker = false
    @State private var selectedFileURL: URL?

    @State private var reportTitle = ""
    @State private var reportType = "Blood Test"

    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let reportTypes = [
        "Blood Test",
        "Urine Test",
        "X-Ray",
        "MRI",
        "CT Scan",
        "Prescription",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && reports.isEmpty {
                    ProgressView("Loading reports...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage, reports.isEmpty {
                    errorView(errorMessage)
                } else {
                    reportList
                }
            }
            .navigationTitle("Reports")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await loadReports()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading || isUploading)
                }
            }
            .task {
                await loadReports()
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.pdf, .jpeg, .png],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    selectedFileURL = url

                    if reportTitle.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty {
                        reportTitle = url.deletingPathExtension()
                            .lastPathComponent
                    }

                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            .alert(
                "Report Status",
                isPresented: Binding(
                    get: {
                        errorMessage != nil || successMessage != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            errorMessage = nil
                            successMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                    successMessage = nil
                }
            } message: {
                Text(errorMessage ?? successMessage ?? "")
            }
        }
    }

    // MARK: - Report List

    private var reportList: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Label(
                        "Upload New Report",
                        systemImage: "doc.badge.plus"
                    )
                    .font(.headline)

                    TextField("Report title", text: $reportTitle)
                        .textFieldStyle(.roundedBorder)

                    Picker("Report type", selection: $reportType) {
                        ForEach(reportTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }

                    Button {
                        showingFilePicker = true
                    } label: {
                        Label(
                            selectedFileURL?.lastPathComponent
                                ?? "Choose PDF or Image",
                            systemImage: "folder"
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        Task {
                            await uploadSelectedReport()
                        }
                    } label: {
                        HStack {
                            if isUploading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.up.doc.fill")
                            }

                            Text(
                                isUploading
                                    ? "Uploading..."
                                    : "Upload Report"
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        isUploading ||
                        selectedFileURL == nil ||
                        reportTitle.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
                .padding(.vertical, 8)
            }

            Section("My Medical Reports") {
                if reports.isEmpty {
                    ContentUnavailableView(
                        "No Reports Yet",
                        systemImage: "doc.text",
                        description: Text(
                            "Upload a medical report to get started."
                        )
                    )
                } else {
                    ForEach(reports) { report in
                        reportRow(report)
                    }
                }
            }
        }
        .refreshable {
            await loadReports()
        }
    }

    // MARK: - Individual Report

    private func reportRow(_ report: MedicalReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 48, height: 48)
                    .background(
                        Color.blue.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: 12)
                    )

                VStack(alignment: .leading, spacing: 5) {
                    Text(report.title)
                        .font(.headline)

                    Text(report.report_type)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Date: \(formattedDate(report.report_date))")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label(
                        report.status.capitalized,
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.green)
                }

                Spacer(minLength: 0)
            }

            NavigationLink {
                AIReportAnalysisView(
                    reportID: report.id,
                    reportTitle: report.title
                )
            } label: {
                Label("Analyze with MedAI", systemImage: "sparkles")
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label(
                "Couldn't Load Reports",
                systemImage: "exclamationmark.triangle"
            )
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await loadReports()
                }
            }
        }
    }

    // MARK: - Load Reports

    @MainActor
    private func loadReports() async {
        guard !isLoading else { return }

        isLoading = true
        defer {
            isLoading = false
        }

        do {
            reports = try await ReportService.shared.fetchReports()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("Loading reports failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Upload Report

    @MainActor
    private func uploadSelectedReport() async {
        guard let fileURL = selectedFileURL else { return }

        isUploading = true
        defer {
            isUploading = false
        }

        do {
            let uploadedReport = try await ReportService.shared.uploadReport(
                fileURL: fileURL,
                title: reportTitle.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                reportType: reportType
            )

            reports.insert(uploadedReport, at: 0)
            selectedFileURL = nil
            reportTitle = ""
            successMessage = "Your report was uploaded successfully."

        } catch {
            errorMessage = error.localizedDescription
            print("Upload error: \(error.localizedDescription)")
        }
    }

    // MARK: - Format Date

    private func formattedDate(_ value: String?) -> String {
        guard let value, !value.isEmpty else {
            return "Not available"
        }

        let formatter = ISO8601DateFormatter()

        if let date = formatter.date(from: value) {
            return date.formatted(
                date: .abbreviated,
                time: .omitted
            )
        }

        return String(value.prefix(10))
    }
}

#Preview {
    ReportsView()
}
