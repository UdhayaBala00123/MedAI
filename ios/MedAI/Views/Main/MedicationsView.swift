
import SwiftUI

struct MedicationsView: View {
    @State private var medications: [Medication] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAddForm = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && medications.isEmpty {
                    ProgressView("Loading medications...")
                } else if medications.isEmpty {
                    emptyState
                } else {
                    medicationList
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await loadMedications()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh medications")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add medication")
                }
            }
            .sheet(isPresented: $showingAddForm) {
                AddMedicationView {
                    await loadMedications()
                }
            }
            .task {
                await loadMedications()
            }
            .alert(
                "Medications",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Medications",
            systemImage: "pills",
            description: Text(
                "Tap + to add your first medication."
            )
        )
    }

    private var medicationList: some View {
        List {
            ForEach(medications) { medication in
                VStack(alignment: .leading, spacing: 8) {
                    NavigationLink {
                        ReminderManagementView(medication: medication)
                    } label: {
                        Label("Manage Reminders", systemImage: "alarm")
                            .font(.subheadline)
                    }
                    .padding(.top, 4)
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundStyle(.blue)

                        Text(medication.medicine_name)
                            .font(.headline)

                        Spacer()

                        Text(medication.active ? "Active" : "Inactive")
                            .font(.caption)
                            .foregroundStyle(
                                medication.active ? .green : .secondary
                            )
                    }

                    Text("Dosage: \(medication.displayDosage)")
                        .font(.subheadline)

                    Text("Frequency: \(medication.frequency)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(medication.displayInstructions)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        "Start: \(medication.start_date.formatted(date: .abbreviated, time: .omitted))"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if let endDate = medication.end_date {
                        Text(
                            "End: \(endDate.formatted(date: .abbreviated, time: .omitted))"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            await deleteMedication(medication)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .refreshable {
            await loadMedications()
        }
    }

    @MainActor
    private func loadMedications() async {
        isLoading = true
        defer { isLoading = false }

        do {
            medications = try await MedicationService.shared.getMedications()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func deleteMedication(_ medication: Medication) async {
        do {
            try await MedicationService.shared.deleteMedication(id: medication.id)
            medications.removeAll { $0.id == medication.id }
        } catch {
            errorMessage = "Could not delete medication: \(error.localizedDescription)"
        }
    }
}

private struct AddMedicationView: View {
    let onSaved: () async -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var medicineName = ""
    @State private var dosage = ""
    @State private var dosageUnit = "mg"
    @State private var frequency = "daily"
    @State private var instructions = ""
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let units = ["mg", "g", "mcg", "mL", "tablet", "capsule"]
    private let frequencies = [
        "daily",
        "twice daily",
        "three times daily",
        "weekly",
        "as needed"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Medicine details") {
                    TextField("Medicine name", text: $medicineName)
                        .autocorrectionDisabled()

                    TextField("Dosage (e.g. 500)", text: $dosage)
                        .keyboardType(.decimalPad)

                    Picker("Unit", selection: $dosageUnit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }

                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { item in
                            Text(item.capitalized).tag(item)
                        }
                    }

                    TextField("Instructions (optional)", text: $instructions)
                }

                Section("Schedule") {
                    DatePicker(
                        "Start date",
                        selection: $startDate,
                        displayedComponents: .date
                    )

                    Toggle("Set end date", isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker(
                            "End date",
                            selection: $endDate,
                            in: startDate...,
                            displayedComponents: .date
                        )
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveMedication()
                        }
                    }
                    .disabled(
                        isSaving ||
                        medicineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
    }

    @MainActor
    private func saveMedication() async {
        isSaving = true
        defer { isSaving = false }

        let medication = MedicationCreate(
            medicine_name: medicineName.trimmingCharacters(in: .whitespacesAndNewlines),
            dosage: dosage.trimmingCharacters(in: .whitespacesAndNewlines),
            dosage_unit: dosageUnit,
            instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : instructions.trimmingCharacters(in: .whitespacesAndNewlines),
            frequency: frequency,
            start_date: Calendar.current.startOfDay(for: startDate),
            end_date: hasEndDate
                ? Calendar.current.startOfDay(for: endDate)
                : nil
        )

        do {
            _ = try await MedicationService.shared.addMedication(medication)
            await onSaved()
            dismiss()
        } catch {
            errorMessage = "Could not save medication: \(error.localizedDescription)"
        }
    }
}

#Preview {
    MedicationsView()
}
