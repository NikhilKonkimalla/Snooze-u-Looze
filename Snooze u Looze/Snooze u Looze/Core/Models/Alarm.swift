//
//  Alarm.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import Foundation

struct Alarm: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var alarmTime: Date
    var task: AlarmTask
    var isActive: Bool
    var repeatDays: [Int]? // 0 = Sunday, 1 = Monday, etc.
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case alarmTime = "alarm_time"
        case task
        case isActive = "is_active"
        case repeatDays = "repeat_days"
        case createdAt = "created_at"
    }
    
    init(id: UUID = UUID(), userId: UUID, alarmTime: Date, task: AlarmTask, isActive: Bool = true, repeatDays: [Int]? = nil, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.alarmTime = alarmTime
        self.task = task
        self.isActive = isActive
        self.repeatDays = repeatDays
        self.createdAt = createdAt
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: alarmTime)
        // Replace regular space with non-breaking space to prevent AM/PM wrapping
        return timeString.replacingOccurrences(of: " ", with: "\u{00A0}")
    }
    
    var nextTriggerDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        
        // Get time components from alarm
        let alarmComponents = calendar.dateComponents([.hour, .minute], from: alarmTime)
        
        // Create date with today's date and alarm's time
        var nextDate = calendar.date(bySettingHour: alarmComponents.hour ?? 0,
                                      minute: alarmComponents.minute ?? 0,
                                      second: 0,
                                      of: now)
        
        // If the time has passed today, move to tomorrow
        if let next = nextDate, next <= now {
            nextDate = calendar.date(byAdding: .day, value: 1, to: next)
        }
        
        return nextDate
    }
}

