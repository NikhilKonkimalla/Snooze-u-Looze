//
//  Alarm Sound Generator
//  This file helps generate a custom alarm sound
//

import Foundation
import AVFoundation

// MARK: - Alarm Sound Generator
// This is a helper class to generate alarm sounds programmatically
// You can use this to create custom alarm audio files

class AlarmSoundGenerator {
    
    static func generateAlarmTone() -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let alarmURL = documentsPath.appendingPathComponent("custom_alarm.wav")
        
        // Create a simple alarm tone using AVAudioEngine
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attach(player)
        
        // Create a simple sine wave alarm tone
        let sampleRate: Double = 44100
        let duration: Double = 1.0 // 1 second
        let frequency: Double = 800 // Hz - typical alarm frequency
        
        let frameCount = UInt32(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!, frameCapacity: frameCount)!
        
        buffer.frameLength = frameCount
        
        let channelData = buffer.floatChannelData![0]
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let sample = Float(sin(2.0 * .pi * frequency * time))
            channelData[frame] = sample * 0.5 // Reduce volume slightly
        }
        
        // Connect to output
        engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
        
        do {
            try engine.start()
            player.scheduleBuffer(buffer, at: nil, options: .loops)
            player.play()
            
            // Note: This is a simplified version
            // For a real implementation, you'd want to save the audio to a file
            return alarmURL
        } catch {
            print("Failed to generate alarm tone: \(error)")
            return nil
        }
    }
}

// MARK: - Instructions for Creating Custom Alarm Sound
/*
 
 TO CREATE A CUSTOM ALARM SOUND:
 
 1. Use any audio editing software (Audacity, GarageBand, etc.)
 2. Create a 1-2 second alarm tone with these characteristics:
    - Frequency: 800-1000 Hz (typical alarm frequency)
    - Volume: Loud but not distorted
    - Format: WAV or MP3
    - Sample Rate: 44.1 kHz
 
 3. Save the file as "alarm.wav" or "alarm.mp3"
 4. Add it to your Xcode project:
    - Drag the file into your Xcode project
    - Make sure "Add to target" is checked
    - The file will be included in your app bundle
 
 5. The AlarmSoundService will automatically find and use this file
 
 ALTERNATIVE: Use system sounds
 - The app will fall back to system sounds if no custom file is found
 - System sounds are already configured to be loud and continuous
 
 */





