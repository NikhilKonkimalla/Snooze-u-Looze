//
//  Snooze_u_LoozeApp.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI
import UserNotifications

@main
struct Snooze_u_LoozeApp: App {
    @StateObject private var supabaseService = SupabaseService.shared
    @StateObject private var notificationService = NotificationService.shared
    @State private var currentAlarm: Alarm?
    @State private var showAlarmRinging = false
    
    init() {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Request notification permissions
        Task {
            try? await NotificationService.shared.requestAuthorization()
        }
        
        // Setup notification categories
        setupNotificationCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if supabaseService.currentUser != nil {
                    AlarmListView()
                } else {
                    LoginView()
                }
            }
            .fullScreenCover(isPresented: $showAlarmRinging) {
                if let alarm = currentAlarm {
                    AlarmRingingView(alarm: alarm) {
                        showAlarmRinging = false
                        currentAlarm = nil
                    }
                }
            }
            .onAppear {
                NotificationDelegate.shared.onAlarmTriggered = { alarm in
                    currentAlarm = alarm
                    showAlarmRinging = true
                }
            }
        }
    }
    
    private func setupNotificationCategories() {
        let stopAction = UNNotificationAction(
            identifier: Constants.Notifications.stopAlarmAction,
            title: "Stop Alarm",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: Constants.Notifications.alarmCategory,
            actions: [stopAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationDelegate()
    
    var onAlarmTriggered: ((Alarm) -> Void)?
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleAlarmNotification(notification)
        completionHandler([.banner, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleAlarmNotification(response.notification)
        completionHandler()
    }
    
    private func handleAlarmNotification(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        guard let alarmIdString = userInfo["alarmId"] as? String,
              let alarmId = UUID(uuidString: alarmIdString),
              let taskString = userInfo["task"] as? String,
              let task = AlarmTask(rawValue: taskString) else {
            return
        }
        
        // Create alarm object from notification data
        let alarm = Alarm(
            id: alarmId,
            userId: UUID(), // Will be filled from actual data
            alarmTime: Date(),
            task: task
        )
        
        DispatchQueue.main.async {
            self.onAlarmTriggered?(alarm)
        }
    }
}
