//
//  AlarmCard.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI

struct AlarmCard: View {
    let alarm: Alarm
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @State private var showDeleteConfirmation = false
    @State private var isToggled: Bool
    
    init(alarm: Alarm, onToggle: @escaping () -> Void, onDelete: @escaping () -> Void, onEdit: @escaping () -> Void) {
        self.alarm = alarm
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.onEdit = onEdit
        self._isToggled = State(initialValue: alarm.isActive)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Time and task info
                VStack(alignment: .leading, spacing: 4) {
                    Text(alarm.timeString)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text(alarm.task.displayName)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    if let repeatDays = alarm.repeatDays, !repeatDays.isEmpty {
                        Text(repeatDaysText)
                            .font(.caption)
                            .foregroundColor(.accentPrimary)
                    }
                }
                
                Spacer()
                
                // Toggle switch
                Toggle("", isOn: $isToggled)
                    .toggleStyle(SwitchToggleStyle(tint: .accentPrimary))
                    .onChange(of: isToggled) { _, newValue in
                        print("🔧 AlarmCard toggle changed to: \(newValue)")
                        onToggle()
                    }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.caption)
                    .foregroundColor(.accentPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentPrimary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onAppear {
            // Sync toggle state with alarm data when view appears
            isToggled = alarm.isActive
        }
        .onChange(of: alarm.isActive) { _, newValue in
            // Sync toggle state when alarm data changes externally
            isToggled = newValue
        }
        .alert("Delete Alarm", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this alarm? This action cannot be undone.")
        }
    }
    
    private var repeatDaysText: String {
        guard let repeatDays = alarm.repeatDays, !repeatDays.isEmpty else { return "" }
        
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let selectedDays = repeatDays.map { dayNames[$0] }
        
        if selectedDays.count == 7 {
            return "Every day"
        } else if selectedDays.count == 2 && repeatDays.contains(0) && repeatDays.contains(6) {
            return "Weekends"
        } else if selectedDays.count == 5 && !repeatDays.contains(0) && !repeatDays.contains(6) {
            return "Weekdays"
        } else {
            return selectedDays.joined(separator: ", ")
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AlarmCard(
            alarm: Alarm(
                userId: UUID(),
                alarmTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date(),
                task: .brushingTeeth,
                isActive: true,
                repeatDays: [1, 2, 3, 4, 5] // Weekdays
            ),
            onToggle: { print("Toggle") },
            onDelete: { print("Delete") },
            onEdit: { print("Edit") }
        )
        
        AlarmCard(
            alarm: Alarm(
                userId: UUID(),
                alarmTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
                task: .openingLaptop,
                isActive: false,
                repeatDays: [0, 6] // Weekends
            ),
            onToggle: { print("Toggle") },
            onDelete: { print("Delete") },
            onEdit: { print("Edit") }
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
