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
            if camera.isAuthorized && camera.isSessionRunning {
                CameraPreview(camera: camera)
                    .ignoresSafeArea()
            } else if let error = camera.setupError {
                // Camera setup error
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Camera Error")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(error)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Retry") {
                        camera.setupCamera()
                    }
                    .padding()
                    .background(Color.accentPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
            } else {
                // Permission denied or not granted
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Please enable camera access in Settings to verify your task")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Open Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .padding()
                    .background(Color.accentPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
            }
            
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
                    print("Capture button pressed")
                    camera.capturePhoto()
                }) {
                    Circle()
                        .fill(camera.isSessionRunning ? Color.white : Color.gray)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(camera.isSessionRunning ? Color.white : Color.gray, lineWidth: 4)
                                .frame(width: 82, height: 82)
                        )
                }
                .disabled(!camera.isSessionRunning)
                .opacity(camera.isSessionRunning ? 1.0 : 0.6)
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
            print("CameraView appeared - checking permissions")
            camera.checkPermissions()
        }
        .onDisappear {
            print("CameraView disappeared - stopping camera session")
            camera.stopSession()
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
    @Published var isSessionRunning = false
    @Published var setupError: String?
    
    var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func checkPermissions() {
        print("Checking camera permissions...")
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("Current camera permission status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            print("Camera already authorized")
            DispatchQueue.main.async {
                self.isAuthorized = true
                self.setupCamera()
            }
        case .notDetermined:
            print("Camera permission not determined - requesting...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                print("Camera permission request result: \(granted)")
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted {
                        print("Camera permission granted - setting up camera")
                        self.setupCamera()
                    } else {
                        print("Camera permission denied by user")
                    }
                }
            }
        case .denied:
            print("Camera permission denied - user must enable in Settings")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        case .restricted:
            print("Camera permission restricted - device policy prevents access")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        @unknown default:
            print("Unknown camera permission status: \(status.rawValue)")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        }
    }
    
    func setupCamera() {
        print("Setting up camera...")
        
        // Clear any previous error
        setupError = nil
        
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            let error = "Failed to get camera device"
            print("\(error)")
            DispatchQueue.main.async {
                self.setupError = error
            }
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            let error = "Failed to create camera input"
            print("\(error)")
            DispatchQueue.main.async {
                self.setupError = error
            }
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
            print("Camera input added successfully")
        } else {
            let error = "Cannot add camera input"
            print("\(error)")
            DispatchQueue.main.async {
                self.setupError = error
            }
            return
        }
        
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            photoOutput = output
            print("Photo output added successfully")
        } else {
            let error = "Cannot add photo output"
            print("\(error)")
            DispatchQueue.main.async {
                self.setupError = error
            }
            return
        }
        
        captureSession = session
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
            print("Camera session started: \(session.isRunning)")
            
            DispatchQueue.main.async {
                self.isSessionRunning = session.isRunning
                if !session.isRunning {
                    self.setupError = "Camera session failed to start"
                }
            }
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
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.setupCamera(camera.captureSession)
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        // Update camera session if it changed
        if uiView.cameraSession !== camera.captureSession {
            uiView.setupCamera(camera.captureSession)
        }
    }
}

class CameraPreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraSession: AVCaptureSession?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
    }
    
    func setupCamera(_ session: AVCaptureSession?) {
        print("Setting up camera preview")
        
        // Remove existing preview layer
        previewLayer?.removeFromSuperlayer()
        
        guard let session = session else {
            print("No camera session provided")
            return
        }
        
        cameraSession = session
        
        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        newPreviewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(newPreviewLayer)
        previewLayer = newPreviewLayer
        
        print("Camera preview layer added")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        print("Camera preview frame updated: \(bounds)")
    }
}

#Preview {
    CameraView(
        task: .brushingTeeth,
        onVerificationSuccess: {},
        onVerificationFailure: {}
    )
}

