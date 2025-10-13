//
//  AlarmRingingView.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI

struct AlarmRingingView: View {
    let alarm: Alarm
    let onDismiss: () -> Void
    
    @StateObject private var soundService = AlarmSoundService.shared
    @State private var showCamera = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            if showCamera {
                CameraView(
                    task: alarm.task,
                    onVerificationSuccess: {
                        soundService.stopAlarm()
                        onDismiss()
                    },
                    onVerificationFailure: {
                        showCamera = false
                    }
                )
            } else {
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Alarm Icon with Animation
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.accentPrimary)
                        .scaleEffect(scale)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true),
                            value: scale
                        )
                    
                    // Time Display
                    Text(alarm.timeString)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    // Task Info
                    VStack(spacing: 12) {
                        Text("Complete your task:")
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                        
                        HStack(spacing: 12) {
                            Image(systemName: alarm.task.icon)
                                .font(.title)
                                .foregroundColor(.accentPrimary)
                            
                            Text(alarm.task.displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                    }
                    
                    Spacer()
                    
                    // Take Photo Button
                    RoundedButton(
                        title: "Take Photo to Stop Alarm",
                        action: {
                            showCamera = true
                        }
                    )
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            scale = 1.2
            soundService.startAlarm()
        }
        .onDisappear {
            soundService.stopAlarm()
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    AlarmRingingView(
        alarm: Alarm(
            userId: UUID(),
            alarmTime: Date(),
            task: .brushingTeeth
        ),
        onDismiss: {}
    )
}

