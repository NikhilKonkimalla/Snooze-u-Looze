import Foundation
import AVFoundation
import AudioToolbox
import MediaPlayer

class AlarmSoundService: ObservableObject {
    static let shared = AlarmSoundService()
    
    @Published var isPlaying = false
    @Published var isBackgroundAudioEnabled = false
    
    private var audioPlayer: AVAudioPlayer?
    private var alarmTimer: Timer?
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private init() {
        setupAudioSession()
        checkBackgroundAudioPermission()
    }
    
    private func setupAudioSession() {
        do {
            // Use .playback category for better compatibility with notifications
            // This allows notifications to play sound while preserving alarm audio
            try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
            try audioSession.setActive(true)
            print("Audio session configured for playback with notification compatibility")
        } catch {
            print("Failed to setup audio session: \(error)")
            // Fallback to simpler configuration
            do {
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true)
                print("Audio session configured with fallback settings")
            } catch {
                print("Failed to setup audio session even with fallback: \(error)")
            }
        }
    }
    
    private func checkBackgroundAudioPermission() {
        // Check if background audio is enabled in app settings
        let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String] ?? []
        isBackgroundAudioEnabled = backgroundModes.contains("audio")
        
        if !isBackgroundAudioEnabled {
            print("Background audio not enabled - alarms may not work when app is backgrounded")
        }
    }
    
    func startAlarm() {
        print("Starting continuous alarm sound...")
        print("isPlaying: \(isPlaying)")
        print("Background audio enabled: \(isBackgroundAudioEnabled)")
        
        guard !isPlaying else { 
            print("Alarm already playing")
            return 
        }
        
        // Request background audio permission if needed
        requestBackgroundAudioPermissionIfNeeded()
        
        // Start background task to keep audio playing
        startBackgroundTask()
        
        // Use iOS system alarm sounds for familiar experience
        print("Playing iOS alarm sound")
        playIOSAlarmSound()
        
        isPlaying = true
    }
    
    func stopAlarm() {
        print("Stopping alarm sound...")
        audioPlayer?.stop()
        audioPlayer = nil
        alarmTimer?.invalidate()
        alarmTimer = nil
        endBackgroundTask()
        isPlaying = false
        print("Alarm sound stopped")
    }
    
    // MARK: - Background Audio Management
    
    private func startBackgroundTask() {
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "AlarmSound") {
            // Background task expired - try to extend it
            self.endBackgroundTask()
            self.startBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskId != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            backgroundTaskId = .invalid
        }
    }
    
    private func requestBackgroundAudioPermissionIfNeeded() {
        guard !isBackgroundAudioEnabled else { return }
        
        // Show alert to user about background audio
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let alert = UIAlertController(
                    title: "Background Audio Required",
                    message: "To ensure alarms continue ringing when your device is locked, please enable Background App Refresh for Snooze u Looze in Settings > General > Background App Refresh.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                })
                
                alert.addAction(UIAlertAction(title: "Continue Anyway", style: .cancel))
                
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
    
    private func playIOSAlarmSound() {
        // Use iOS system alarm sounds for familiar alarm experience
        print("Playing iOS alarm sound...")
        
        // Try to load iOS system alarm sounds
        if let alarmSoundURL = getIOSAlarmSoundURL() {
            playIOSAlarmSoundFile(url: alarmSoundURL)
        } else {
            // Fallback to system sound IDs
            playSystemAlarmSounds()
        }
    }
    
    private func getIOSAlarmSoundURL() -> URL? {
        // Try to access iOS system alarm sounds
        let systemSoundsPath = "/System/Library/Audio/UISounds"
        
        // Common iOS alarm sound file names
        let alarmSoundNames = [
            "alarm.caf",           // Classic iOS alarm
            "alarm_clock.caf",     // Alternative alarm
            "critical_alert.caf",  // Critical alert sound
            "emergency_alert.caf", // Emergency alert
            "wake_up.caf"         // Wake up sound
        ]
        
        for soundName in alarmSoundNames {
            let soundPath = systemSoundsPath + "/" + soundName
            let soundURL = URL(fileURLWithPath: soundPath)
            
            if FileManager.default.fileExists(atPath: soundPath) {
                print("Found iOS alarm sound: \(soundName)")
                return soundURL
            }
        }
        
        print("No iOS alarm sound files found, using system sound IDs")
        return nil
    }
    
    private func playIOSAlarmSoundFile(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            
            // Configure for maximum volume and continuous playback
            try audioSession.setActive(true)
            
            let success = audioPlayer?.play() ?? false
            if success {
                print("iOS alarm sound playing continuously")
            } else {
                print("Failed to start iOS alarm sound, using fallback")
                playSystemAlarmSounds()
            }
        } catch {
            print("Failed to play iOS alarm sound: \(error)")
            playSystemAlarmSounds()
        }
    }
    
    private func playSystemAlarmSounds() {
        // Fallback to system sound IDs - these are the same sounds iOS Clock app uses
        print("Playing iOS system alarm sounds...")
        
        // Use a timer to play system sounds continuously
        alarmTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard self.isPlaying else {
                timer.invalidate()
                return
            }
            
            // Play the classic iOS alarm sound (same as Clock app)
            AudioServicesPlaySystemSound(1005) // This is the actual iOS alarm sound
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            print("iOS alarm sound played")
        }
        
        // Play immediately
        AudioServicesPlaySystemSound(1005)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        print("iOS system alarm started - playing every 1 second")
    }
    
    // MARK: - Test Method (for debugging)
    
    func testAlarmSound() {
        print("Testing alarm sound...")
        startAlarm()
        
        // Stop after 5 seconds for testing
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("Test alarm stopping...")
            self.stopAlarm()
        }
    }
}

