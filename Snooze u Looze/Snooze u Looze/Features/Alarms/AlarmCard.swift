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
    
    var body: some View {
        HStack(spacing: 16) {
            // Task Icon
            Image(systemName: alarm.task.icon)
                .font(.system(size: 28))
                .foregroundColor(.accentPrimary)
                .frame(width: 50, height: 50)
                .background(Color.accentPrimary.opacity(0.15))
                .cornerRadius(12)
            
            // Time and Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(alarm.task.displayName)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    if let repeatDays = alarm.repeatDays, !repeatDays.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "repeat")
                                .font(.caption2)
                                .foregroundColor(.accentPrimary)
                            
                            Text(formatRepeatDays(repeatDays))
                                .font(.caption2)
                                .foregroundColor(.accentPrimary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Edit Button
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentPrimary)
            }
            .padding(.trailing, 8)
            
            // Toggle Switch
            Toggle("", isOn: Binding(
                get: { alarm.isActive },
                set: { _ in onToggle() }
            ))
            .tint(.accentPrimary)
        }
        .padding(AppTheme.cardPadding)
        .roundedCard()
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func formatRepeatDays(_ repeatDays: [Int]) -> String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let sortedDays = repeatDays.sorted()
        
        if sortedDays == [1, 2, 3, 4, 5] {
            return "Weekdays"
        } else if sortedDays == [0, 6] {
            return "Weekends"
        } else if sortedDays.count == 7 {
            return "Daily"
        } else {
            return sortedDays.map { dayNames[$0] }.joined(separator: ", ")
        }
    }
}

#Preview {
    VStack {
        AlarmCard(
            alarm: Alarm(
                userId: UUID(),
                alarmTime: Date(),
                task: .brushingTeeth
            ),
            onToggle: {},
            onDelete: {},
            onEdit: {}
        )
        
        AlarmCard(
            alarm: Alarm(
                userId: UUID(),
                alarmTime: Date(),
                task: .openingLaptop,
                isActive: false
            ),
            onToggle: {},
            onDelete: {},
            onEdit: {}
        )
    }
    .padding()
    .background(Color.appBackground)
}


