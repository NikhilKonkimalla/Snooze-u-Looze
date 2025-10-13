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
                
                Text(alarm.task.displayName)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
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
            onDelete: {}
        )
        
        AlarmCard(
            alarm: Alarm(
                userId: UUID(),
                alarmTime: Date(),
                task: .openingLaptop,
                isActive: false
            ),
            onToggle: {},
            onDelete: {}
        )
    }
    .padding()
    .background(Color.appBackground)
}

