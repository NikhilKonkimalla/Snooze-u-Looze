import SwiftUI
import AVFoundation

struct AlarmRingingView: View {
    let alarm: Alarm
    let onDismiss: () -> Void
    
    @StateObject private var soundService = AlarmSoundService.shared
    @State private var showCamera = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Camera view when shown
            if showCamera {
                CameraView(
                    task: alarm.task,
                    onVerificationSuccess: {
                        print("Task verification successful!")
                        soundService.stopAlarm()
                        onDismiss()
                    },
                    onVerificationFailure: {
                        print("Task verification failed - keep alarm ringing")
                        // Keep the alarm ringing until verification succeeds
                    }
                )
            } else {
                // Alarm screen with task info
                Color.red
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Alarm icon and title
                    VStack(spacing: 16) {
                        Image(systemName: "alarm.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .scaleEffect(scale)
                        
                        Text("Time to wake up!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Complete your task: \(alarm.task.displayName)")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 20) {
                        Button("Take Photo to Verify") {
                            print("Starting camera for task verification")
                            print("Requesting camera permission first...")
                            
                            // Request camera permission first
                            AVCaptureDevice.requestAccess(for: .video) { granted in
                                print("Camera permission result: \(granted)")
                                DispatchQueue.main.async {
                                    if granted {
                                        print("Camera permission granted - showing camera")
                                        showCamera = true
                                    } else {
                                        print("Camera permission denied")
                                        // Could show an alert here
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(Color.white)
                        .foregroundColor(.red)
                        .font(.title2)
                        .fontWeight(.bold)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        
                        // Debug buttons for testing
                        VStack(spacing: 12) {
                            Button("Debug: Check Camera Permission") {
                                // Check Info.plist content
                                if let cameraUsage = Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") as? String {
                                    print("Info.plist camera usage description: \(cameraUsage)")
                                } else {
                                    print("No NSCameraUsageDescription found in Info.plist!")
                                }
                                
                                let status = AVCaptureDevice.authorizationStatus(for: .video)
                                print("Current camera permission status: \(status.rawValue)")
                                print("Status description: \(status)")
                                
                                switch status {
                                case .authorized:
                                    print("Camera is authorized")
                                case .denied:
                                    print("Camera is denied")
                                case .notDetermined:
                                    print("Camera permission not determined")
                                case .restricted:
                                    print("Camera is restricted")
                                @unknown default:
                                    print("Unknown camera status")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .font(.caption)
                            .cornerRadius(8)
                            
                            Button("Debug: Mark as Verified") {
                                print("DEBUG: Task marked as verified")
                                soundService.stopAlarm()
                                onDismiss()
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            print("AlarmRingingView appeared for task: \(alarm.task.displayName)")
            scale = 1.2
            print("AlarmRingingView ready - alarm should already be playing")
        }
        .onDisappear {
            print("AlarmRingingView disappeared")
            soundService.stopAlarm()
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    AlarmRingingView(
        alarm: Alarm(
            userId: UUID(),
            alarmTime: Date(),
            task: .brushingTeeth
        ),
        onDismiss: {}
    )
}


