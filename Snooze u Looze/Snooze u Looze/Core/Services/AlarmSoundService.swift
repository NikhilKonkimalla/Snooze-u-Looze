//
//  AlarmSoundService.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import Foundation
import AVFoundation
import AudioToolbox

class AlarmSoundService: ObservableObject {
    static let shared = AlarmSoundService()
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    @Published var isPlaying = false
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            // Use .playback category to keep playing even when device is locked
            // Remove mixWithOthers to stop other audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startAlarm() {
        print("🔊 Starting alarm sound...")
        guard !isPlaying else { 
            print("🔊 Alarm already playing")
            return 
        }
        
        // Try custom alarm sound first, fallback to system sound
        if let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") ??
                          Bundle.main.url(forResource: "alarm", withExtension: "wav") {
            print("🔊 Playing custom alarm sound")
            playCustomSound(url: soundURL)
        } else {
            print("🔊 Playing system alarm sound")
            // Fallback: use system vibration + repeating tone
            playSystemAlarm()
        }
        
        isPlaying = true
    }
    
    func stopAlarm() {
        audioPlayer?.stop()
        audioPlayer = nil
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }
    
    private func playCustomSound(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play custom alarm sound: \(error)")
            playSystemAlarm()
        }
    }
    
    private func playSystemAlarm() {
        // Play a system sound repeatedly using timer - more frequent for louder effect
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // System sound ID 1005 is a loud alert tone
            AudioServicesPlaySystemSound(1005)
            // Also vibrate
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        // Play immediately
        AudioServicesPlaySystemSound(1005)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        print("🔊 System alarm started - playing every 1 second")
    }
}

