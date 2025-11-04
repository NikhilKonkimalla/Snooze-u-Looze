//
//  NotificationService.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import Foundation
import UserNotifications

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    
    override private init() {
        super.init()
        checkAuthorization()
    }
    
    func requestAuthorization() async throws {
        // Request critical alert permissions first
        let criticalGranted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
        
        // Then request regular notification permissions
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        
        await MainActor.run {
            self.isAuthorized = granted
            print("✅ Notification permissions granted: \(granted)")
            print("✅ Critical alert permissions granted: \(criticalGranted)")
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleAlarm(_ alarm: Alarm) {
        print("🔔 Attempting to schedule alarm for: \(alarm.timeString)")
        print("🔔 Is authorized: \(isAuthorized)")
        
        guard isAuthorized else { 
            print("❌ Not authorized to send notifications - requesting permissions...")
            Task {
                do {
                    try await requestAuthorization()
                    // Try again after getting permissions
                    if isAuthorized {
                        scheduleAlarm(alarm)
                    }
                } catch {
                    print("❌ Failed to get notification permissions: \(error)")
                }
            }
            return 
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to wake up!"
        content.body = "Complete your task: \(alarm.task.displayName)"
        // Use critical sound for maximum volume and to bypass Do Not Disturb
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = Constants.Notifications.alarmCategory
        content.userInfo = ["alarmId": alarm.id.uuidString, "task": alarm.task.rawValue]
        content.interruptionLevel = .critical
        content.relevanceScore = 1.0
        
        print("🔔 Scheduled notification with critical sound and interruption level")
        
        // Handle repeat days
        if let repeatDays = alarm.repeatDays, !repeatDays.isEmpty {
            // Schedule recurring alarm
            scheduleRecurringAlarm(content: content, alarm: alarm, repeatDays: repeatDays)
        } else {
            // Schedule one-time alarm
            scheduleOneTimeAlarm(content: content, alarm: alarm)
        }
    }
    
    private func scheduleOneTimeAlarm(content: UNMutableNotificationContent, alarm: Alarm) {
        guard let triggerDate = alarm.nextTriggerDate else { 
            print("❌ Could not calculate next trigger date for alarm")
            return 
        }
        
        print("🔔 Next trigger date: \(triggerDate)")
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ One-time notification scheduled successfully!")
                print("✅ Notification ID: \(alarm.id.uuidString)")
                print("✅ Trigger date: \(triggerDate)")
            }
        }
    }
    
    private func scheduleRecurringAlarm(content: UNMutableNotificationContent, alarm: Alarm, repeatDays: [Int]) {
        let calendar = Calendar.current
        let alarmTime = calendar.dateComponents([.hour, .minute], from: alarm.alarmTime)
        
        for dayIndex in repeatDays {
            var dateComponents = DateComponents()
            dateComponents.weekday = dayIndex + 1 // Calendar weekday: Sunday = 1, Monday = 2, etc.
            dateComponents.hour = alarmTime.hour
            dateComponents.minute = alarmTime.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "\(alarm.id.uuidString)_\(dayIndex)"
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling recurring notification for day \(dayIndex): \(error)")
                } else {
                    print("✅ Recurring notification scheduled for day \(dayIndex)!")
                }
            }
        }
    }
    
    func cancelAlarm(id: UUID) {
        // Cancel both one-time and recurring notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        
        // Cancel recurring notifications (they have different identifiers)
        for dayIndex in 0..<7 {
            let identifier = "\(id.uuidString)_\(dayIndex)"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        }
    }
    
    // MARK: - Debug Methods
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("🔍 Pending notifications: \(requests.count)")
            for request in requests {
                print("🔍 - ID: \(request.identifier)")
                print("🔍 - Title: \(request.content.title)")
                print("🔍 - Trigger: \(request.trigger?.description ?? "nil")")
            }
        }
    }
    
    func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification"
        content.sound = UNNotificationSound.defaultCritical
        content.interruptionLevel = .critical
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test-\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Test notification failed: \(error)")
            } else {
                print("✅ Test notification scheduled!")
            }
        }
    }
    
    func cancelAllAlarms() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Test function to send immediate notification
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Alarm"
        content.body = "This is a test notification"
        content.sound = UNNotificationSound.defaultCritical
        content.interruptionLevel = .critical
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Test notification failed: \(error)")
            } else {
                print("✅ Test notification scheduled!")
            }
        }
    }
}


