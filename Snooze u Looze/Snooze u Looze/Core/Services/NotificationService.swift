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
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        await MainActor.run {
            self.isAuthorized = granted
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
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to wake up!"
        content.body = "Complete your task: \(alarm.task.displayName)"
        content.sound = .defaultCritical
        content.categoryIdentifier = Constants.Notifications.alarmCategory
        content.userInfo = ["alarmId": alarm.id.uuidString, "task": alarm.task.rawValue]
        
        guard let triggerDate = alarm.nextTriggerDate else { return }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelAlarm(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
    func cancelAllAlarms() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

