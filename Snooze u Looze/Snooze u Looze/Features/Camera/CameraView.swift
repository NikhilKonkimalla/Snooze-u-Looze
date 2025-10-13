//
//  CameraView.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    let task: AlarmTask
    let onVerificationSuccess: () -> Void
    let onVerificationFailure: () -> Void
    
    @StateObject private var camera = CameraModel()
    @State private var isVerifying = false
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            // Overlay
            VStack {
                // Top Bar
                HStack {
                    Text("Capture: \(task.displayName)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Capture Button
                Button(action: {
                    camera.capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 82, height: 82)
                        )
                }
                .padding(.bottom, 40)
            }
            
            // Verification Loading
            if isVerifying {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Verifying task...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
        .onChange(of: camera.capturedImage) { _, newImage in
            if let image = newImage {
                verifyImage(image)
            }
        }
    }
    
    private func verifyImage(_ image: UIImage) {
        isVerifying = true
        
        Task {
            do {
                let isVerified = try await MLVerificationService.shared.verifyTask(task, in: image)
                
                await MainActor.run {
                    isVerifying = false
                    
                    if isVerified {
                        onVerificationSuccess()
                    } else {
                        onVerificationFailure()
                    }
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    onVerificationFailure()
                }
            }
        }
    }
}

// MARK: - Camera Model

class CameraModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isAuthorized = false
    
    var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }
    
    func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            photoOutput = output
        }
        
        captureSession = session
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func stopSession() {
        captureSession?.stopRunning()
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}

// MARK: - Camera Preview

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        if let session = camera.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.main.async {
                previewLayer.frame = view.bounds
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

#Preview {
    CameraView(
        task: .brushingTeeth,
        onVerificationSuccess: {},
        onVerificationFailure: {}
    )
}

