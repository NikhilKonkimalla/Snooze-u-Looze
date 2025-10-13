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
        
        isLoading = true
        errorMessage = nil
        
        do {
            let createdAlarm = try await supabaseService.createAlarm(alarm)
            alarms.append(createdAlarm)
            notificationService.scheduleAlarm(createdAlarm)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleAlarm(_ alarm: Alarm) async {
        var updatedAlarm = alarm
        updatedAlarm.isActive.toggle()
        
        do {
            try await supabaseService.updateAlarm(updatedAlarm)
            
            if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
                alarms[index] = updatedAlarm
            }
            
            if updatedAlarm.isActive {
                notificationService.scheduleAlarm(updatedAlarm)
            } else {
                notificationService.cancelAlarm(id: updatedAlarm.id)
            }
        } catch {
            errorMessage = error.localizedDescription
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

