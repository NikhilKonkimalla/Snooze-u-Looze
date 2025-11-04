//
//  EditAlarmView.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI

struct EditAlarmView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel = AlarmViewModel.shared
    
    let alarm: Alarm
    @State private var selectedTime: Date
    @State private var selectedTask: AlarmTask
    @State private var isActive: Bool
    @State private var repeatDays: Set<Int> // 0 = Sunday, 1 = Monday, etc.
    
    init(alarm: Alarm) {
        self.alarm = alarm
        self._selectedTime = State(initialValue: alarm.alarmTime)
        self._selectedTask = State(initialValue: alarm.task)
        self._isActive = State(initialValue: alarm.isActive)
        self._repeatDays = State(initialValue: Set(alarm.repeatDays ?? []))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacing) {
                        // Time Picker
                        VStack(alignment: .leading, spacing: 8) {
                            DatePicker(
                                "",
                                selection: $selectedTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)
                        }
                        .padding()
                        .roundedCard()
                    
                    // Task Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Task to Complete")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        ForEach(AlarmTask.allCases, id: \.self) { task in
                            TaskOptionButton(
                                task: task,
                                isSelected: selectedTask == task,
                                action: {
                                    selectedTask = task
                                }
                            )
                        }
                    }
                    .padding()
                    .roundedCard()
                    
                    // Repeat Days
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Repeat Days")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                let dayName = Calendar.current.shortWeekdaySymbols[dayIndex]
                                let isSelected = repeatDays.contains(dayIndex)
                                
                                Button(action: {
                                    if isSelected {
                                        repeatDays.remove(dayIndex)
                                    } else {
                                        repeatDays.insert(dayIndex)
                                    }
                                }) {
                                    Text(dayName)
                                        .font(.caption)
                                        .fontWeight(isSelected ? .bold : .regular)
                                        .foregroundColor(isSelected ? .white : .textPrimary)
                                        .frame(width: 40, height: 40)
                                        .background(isSelected ? Color.accentPrimary : Color.cardBackground)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        if repeatDays.isEmpty {
                            Text("No repeat days selected - alarm will ring once")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding()
                    .roundedCard()
                    
                    // Active Toggle
                    HStack {
                        Text("Alarm Active")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isActive)
                            .tint(.accentPrimary)
                    }
                    .padding()
                    .roundedCard()
                    
                    Spacer()
                    
                    // Save Button
                    RoundedButton(
                        title: "Save Changes",
                        action: {
                            Task {
                                await saveChanges()
                            }
                        }
                    )
                    .padding(.horizontal)
                    }
                    .padding()
                    .padding(.bottom, 20) // Extra bottom padding for save button
                }
            }
            .navigationTitle("Alarm Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveChanges() async {
        // Create updated alarm
        var updatedAlarm = alarm
        updatedAlarm.alarmTime = selectedTime
        updatedAlarm.task = selectedTask
        updatedAlarm.isActive = isActive
        updatedAlarm.repeatDays = repeatDays.isEmpty ? nil : Array(repeatDays)
        
        // Update in view model
        await viewModel.updateAlarm(updatedAlarm)
        
        // Dismiss the view
        dismiss()
    }
}

#Preview {
    EditAlarmView(alarm: Alarm(
        userId: UUID(),
        alarmTime: Date(),
        task: .brushingTeeth,
        isActive: true,
        repeatDays: [1, 2, 3, 4, 5] // Weekdays
    ))
}



