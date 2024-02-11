//
//  ReminderView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 08.02.2024.
//

import SwiftUI

struct ReminderView: View {
    @State private var viewModel = ReminderViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Turn on", systemImage: "bell", isOn: $viewModel.isReminderOn)
                        .onChange(of: viewModel.isReminderOn) {
                            if !viewModel.isReminderOn {
                                viewModel.turnOffNotifications()
                            }
                        }

                    DatePicker(selection: $viewModel.selectedTime, displayedComponents: .hourAndMinute) {
                        Label("Choose time", systemImage: "clock")
                    }
                    .onChange(of: viewModel.selectedTime) {
                        if viewModel.isReminderOn {
                            viewModel.saveSelectedTime()
                        }
                    }
                } footer: {
                    Text("Notification will be sent at specified time.")
                }

                Section {
                    ForEach(weekdays) { weekday in
                        Button {
                            if viewModel.isWeekdayInReminder(weekday: weekday) {
                                viewModel.removeNotificationFromReminder(weekday: weekday)
                            } else {
                                viewModel.addWeekdayToReminder(weekday: weekday)
                                Task {
                                    await viewModel.scheduleReminder(for: weekday)
                                }
                            }
                        } label: {
                            HStack {
                                Text(weekday.name)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                                    .opacity(viewModel.isWeekdayInReminder(weekday: weekday) ? 1 : 0)
                            }
                        }
                        .tint(.primary)
                    }
                    .disabled(!viewModel.isReminderOn)
                } header: {
                    Text("Repeat every")
                } footer: {
                    Text("Notification will be sent on the selected days.")
                }
            }
            .navigationTitle("Reminder")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.saveReminderState()
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ReminderView()
}
