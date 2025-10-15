//
//  AlarmViewModel.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import Foundation
import Combine

@MainActor
class AlarmViewModel: ObservableObject {
    static let shared = AlarmViewModel()
    
    @Published var alarms: [Alarm] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabaseService = SupabaseService.shared
    private let notificationService = NotificationService.shared
    
    private init() {}
    
    func fetchAlarms() async {
        isLoading = true
        errorMessage = nil
        
        do {
            alarms = try await supabaseService.fetchAlarms()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createAlarm(time: Date, task: AlarmTask) async {
        guard let userId = supabaseService.currentUser?.id else { return }
        
        let alarm = Alarm(
            userId: userId,
            alarmTime: time,
            task: task
        )
        
        // OPTIMISTIC UPDATE: Add alarm to UI immediately
        alarms.append(alarm)
        notificationService.scheduleAlarm(alarm)
        
        isLoading = true
        errorMessage = nil
        
        // Try to sync with Supabase in background
        do {
            _ = try await supabaseService.createAlarm(alarm)
            // Success - alarm already in list, just clear any errors
            errorMessage = nil
        } catch {
            // Failed to sync to Supabase, but alarm still works locally
            print("⚠️ Failed to sync alarm to Supabase: \(error.localizedDescription)")
            // Don't remove from local list - alarm still works!
            errorMessage = "Alarm created locally (sync failed: \(error.localizedDescription))"
        }
        
        isLoading = false
    }
    
    func toggleAlarm(_ alarm: Alarm) async {
        var updatedAlarm = alarm
        updatedAlarm.isActive.toggle()
        await updateAlarm(updatedAlarm)
    }
    
    func updateAlarm(_ alarm: Alarm) async {
        // Update locally first
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
        }
        
        // Cancel existing notification
        notificationService.cancelAlarm(id: alarm.id)
        
        // Schedule new notification if active
        if alarm.isActive {
            notificationService.scheduleAlarm(alarm)
        }
        
        // Try to sync with Supabase
        do {
            try await supabaseService.updateAlarm(alarm)
            errorMessage = nil
        } catch {
            print("⚠️ Failed to sync alarm update to Supabase: \(error.localizedDescription)")
            errorMessage = "Alarm updated locally (sync failed: \(error.localizedDescription))"
        }
    }
    
    func deleteAlarm(_ alarm: Alarm) async {
        do {
            try await supabaseService.deleteAlarm(id: alarm.id)
            alarms.removeAll { $0.id == alarm.id }
            notificationService.cancelAlarm(id: alarm.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

