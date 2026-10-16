
import SwiftUI

struct EditMedicationReminderView: View {
    let medication: Medication
    let reminder: MedicationReminder
    let onSaved: () async -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var reminderTime = Date()
    @State private var selectedDays: Set<Int> = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let days: [(id: Int, name: String)] = [
        (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat"), (1, "Sun")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Medication") {
                    Text(medication.medicine_name)
                    Text(medication.displayDosage)
                        .foregroundStyle(.secondary)
                }

                Section("Reminder time") {
                    DatePicker(
                        "Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("Repeat on") {
                    HStack(spacing: 6) {
                        ForEach(days, id: \.id) { day in
                            Button {
                                toggleDay(day.id)
                            } label: {
                                Text(day.name)
                                    .font(.caption.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedDays.contains(day.id)
                                            ? Color.blue
                                            : Color.gray.opacity(0.15)
                                    )
                                    .foregroundStyle(
                                        selectedDays.contains(day.id)
                                            ? .white : .primary
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Reminder")
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
                            await saveChanges()
                        }
                    }
                    .disabled(isSaving || selectedDays.isEmpty)
                }
            }
            .onAppear {
                loadInitialValues()
            }
        }
    }

    private func loadInitialValues() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"

        if let parsed = formatter.date(from: reminder.reminder_time) {
            reminderTime = parsed
        }

        let names = Set(
            reminder.days_of_week
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        )

        for day in days {
            if names.contains(day.name.lowercased()) {
                selectedDays.insert(day.id)
            }
        }
    }

    private func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    @MainActor
    private func saveChanges() async {
        isSaving = true
        defer { isSaving = false }

        do {
            let selectedNames = days
                .filter { selectedDays.contains($0.id) }
                .map(\.name)
                .joined(separator: ",")

            let updated = try await MedicationReminderService.shared
                .updateReminder(
                    id: reminder.id,
                    medicationID: medication.id,
                    time: reminderTime,
                    daysOfWeek: selectedNames
                )

            MedicationNotificationService.cancel(
                reminderID: reminder.id
            )

            try await MedicationNotificationService.schedule(
                reminderID: updated.id,
                medicationName: medication.medicine_name,
                time: reminderTime,
                weekdays: Array(selectedDays)
            )

            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
