
import SwiftUI

struct ReminderManagementView: View {
    let medication: Medication

    @State private var reminders: [MedicationReminder] = []

    @State private var reminderTime = Calendar.current.date(
        bySettingHour: 8,
        minute: 0,
        second: 0,
        of: Date()
    ) ?? Date()

    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]

    @State private var editingReminder: MedicationReminder?
    @State private var showingEditReminder = false

    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let days: [(id: Int, name: String)] = [
        (2, "Mon"),
        (3, "Tue"),
        (4, "Wed"),
        (5, "Thu"),
        (6, "Fri"),
        (7, "Sat"),
        (1, "Sun")
    ]

    var body: some View {
        Form {
            medicationSection
            addReminderSection
            savedRemindersSection
        }
        .navigationTitle("Medication Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadReminders()
        }
        .sheet(isPresented: $showingEditReminder) {
            if let reminder = editingReminder {
                EditMedicationReminderView(
                    medication: medication,
                    reminder: reminder
                ) {
                    await loadReminders()
                }
            }
        }
        .alert(
            "Medication Reminders",
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

    // MARK: - Medication

    private var medicationSection: some View {
        Section("Medication") {
            HStack(spacing: 12) {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.medicine_name)
                        .font(.headline)

                    Text(medication.displayDosage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(medication.frequency.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Add Reminder

    private var addReminderSection: some View {
        Section("Add Reminder") {
            DatePicker(
                "Reminder time",
                selection: $reminderTime,
                displayedComponents: .hourAndMinute
            )

            Text("Repeat on")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            weekdaySelector

            Button {
                Task {
                    await addReminder()
                }
            } label: {
                HStack {
                    Spacer()

                    if isSaving {
                        ProgressView()
                    } else {
                        Label(
                            "Add Reminder",
                            systemImage: "alarm"
                        )
                    }

                    Spacer()
                }
            }
            .disabled(isSaving || selectedDays.isEmpty)
        }
    }

    private var weekdaySelector: some View {
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
                                ? Color.white
                                : Color.primary
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(day.name)
                .accessibilityAddTraits(
                    selectedDays.contains(day.id)
                        ? .isSelected
                        : []
                )
            }
        }
    }

    // MARK: - Saved Reminders

    private var savedRemindersSection: some View {
        Section {
            if isLoading {
                ProgressView("Loading reminders...")
            } else if reminders.isEmpty {
                ContentUnavailableView(
                    "No Reminders",
                    systemImage: "alarm",
                    description: Text(
                        "Choose a time above to add your first reminder."
                    )
                )
            } else {
                ForEach(reminders) { reminder in
                    reminderRow(reminder)
                }
            }
        } header: {
            Text("Saved Reminders")
        } footer: {
            Text(
                "Swipe a reminder left for more actions, or use the buttons below each reminder."
            )
        }
    }

    private func reminderRow(
        _ reminder: MedicationReminder
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "alarm.fill")
                    .font(.title2)
                    .foregroundStyle(
                        reminder.active ? .blue : .secondary
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayTime(reminder.reminder_time))
                        .font(.headline)

                    Text(reminder.days_of_week)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(reminder.active ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundStyle(
                        reminder.active ? .green : .secondary
                    )
            }

            HStack {
                Button {
                    editingReminder = reminder
                    showingEditReminder = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(role: .destructive) {
                    Task {
                        await deleteReminder(reminder)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.red)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 6)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    await deleteReminder(reminder)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                editingReminder = reminder
                showingEditReminder = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    // MARK: - Helpers

    private func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    private func displayTime(_ value: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"

        guard let date = formatter.date(from: value) else {
            return value
        }

        return date.formatted(
            date: .omitted,
            time: .shortened
        )
    }

    // MARK: - Load

    @MainActor
    private func loadReminders() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loaded = try await MedicationReminderService.shared
                .getReminders(medicationID: medication.id)

            reminders = loaded.sorted {
                $0.reminder_time < $1.reminder_time
            }

            errorMessage = nil
        } catch {
            errorMessage = "Could not load reminders: \(error.localizedDescription)"
        }
    }

    // MARK: - Add

    @MainActor
    private func addReminder() async {
        guard !selectedDays.isEmpty else {
            errorMessage = "Select at least one weekday."
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await MedicationNotificationService.requestPermission()

            let dayNames = days
                .filter { selectedDays.contains($0.id) }
                .map(\.name)
                .joined(separator: ",")

            let saved = try await MedicationReminderService.shared
                .addReminder(
                    medicationID: medication.id,
                    time: reminderTime,
                    daysOfWeek: dayNames
                )

            do {
                try await MedicationNotificationService.schedule(
                    reminderID: saved.id,
                    medicationName: medication.medicine_name,
                    time: reminderTime,
                    weekdays: Array(selectedDays)
                )
            } catch {
                // The backend record has already been saved.
                // Keep it visible and explain the notification issue.
                reminders.append(saved)
                reminders.sort {
                    $0.reminder_time < $1.reminder_time
                }

                errorMessage =
                    "The reminder was saved, but notification scheduling failed: \(error.localizedDescription)"
                return
            }

            reminders.append(saved)
            reminders.sort {
                $0.reminder_time < $1.reminder_time
            }

            successMessage = "Reminder saved and notifications scheduled."
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    @MainActor
    private func deleteReminder(
        _ reminder: MedicationReminder
    ) async {
        do {
            try await MedicationReminderService.shared
                .deleteReminder(id: reminder.id)

            // Cancel local notifications only after the backend deletion succeeds.
            MedicationNotificationService.cancel(
                reminderID: reminder.id
            )

            reminders.removeAll {
                $0.id == reminder.id
            }

            successMessage = "Reminder deleted."
            errorMessage = nil
        } catch {
            errorMessage =
                "Could not delete reminder: \(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        ReminderManagementView(
            medication: Medication(
                id: 1,
                user_id: 1,
                medicine_name: "Paracetamol",
                dosage: "500",
                dosage_unit: "mg",
                instructions: "After food",
                frequency: "daily",
                start_date: Date(),
                end_date: nil,
                active: true,
                created_at: Date()
            )
        )
    }
}
