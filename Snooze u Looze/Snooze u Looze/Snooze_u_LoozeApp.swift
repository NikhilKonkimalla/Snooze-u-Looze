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
        
        // Request notification permissions immediately
        Task {
            do {
                try await NotificationService.shared.requestAuthorization()
                print("Notification permissions granted")
            } catch {
                print("Failed to get notification permissions: \(error)")
            }
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
                        print("AlarmRingingView dismissed")
                        showAlarmRinging = false
                        currentAlarm = nil
                    }
                }
            }
            .onAppear {
                NotificationDelegate.shared.onAlarmTriggered = { alarm in
                    print("Alarm triggered callback received - showing AlarmRingingView")
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
        print("Notification received in foreground: \(notification.request.identifier)")
        handleAlarmNotification(notification)
        completionHandler([.banner, .sound]) // Include .sound for notification audio
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("Notification tapped: \(response.notification.request.identifier)")
        handleAlarmNotification(response.notification)
        completionHandler()
    }
    
    private func handleAlarmNotification(_ notification: UNNotification) {
        print("Handling alarm notification...")
        let userInfo = notification.request.content.userInfo
        print("User info: \(userInfo)")
        
        guard let alarmIdString = userInfo["alarmId"] as? String,
              let alarmId = UUID(uuidString: alarmIdString),
              let taskString = userInfo["task"] as? String,
              let task = AlarmTask(rawValue: taskString) else {
            print("Failed to parse alarm notification data")
            return
        }
        
        print("Parsed alarm - ID: \(alarmId), Task: \(task)")
        
        // Create alarm object from notification data
        let alarm = Alarm(
            id: alarmId,
            userId: UUID(), // Will be filled from actual data
            alarmTime: Date(),
            task: task
        )
        
        print("Triggering alarm view...")
        print("Starting continuous alarm sound...")
        
        // Start the continuous alarm sound immediately
        AlarmSoundService.shared.startAlarm()
        
        DispatchQueue.main.async {
            self.onAlarmTriggered?(alarm)
        }
    }
}
