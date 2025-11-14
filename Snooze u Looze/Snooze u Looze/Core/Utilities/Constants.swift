import Foundation

struct Constants {
    // IMPORTANT: Replace these with your actual Supabase project credentials
    static let supabaseURL = "https://zdpaqdnacqymbsgowyvi.supabase.co" // e.g., "https://xxxxx.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpkcGFxZG5hY3F5bWJzZ293eXZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzAxMzcsImV4cCI6MjA3NTg0NjEzN30.jlS4xxoAGWTqVzTVuogkCSLrnYk15vmySAwBW2lvuR0"
    
    struct Notifications {
        static let alarmCategory = "ALARM_CATEGORY"
        static let stopAlarmAction = "STOP_ALARM_ACTION"
    }
    
    struct UserDefaults {
        static let currentAlarmId = "currentAlarmId"
    }
}






