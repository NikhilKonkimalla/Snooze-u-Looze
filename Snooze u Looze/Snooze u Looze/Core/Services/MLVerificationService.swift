//
//  MLVerificationService.swift
//  Snooze u Looze
//
//  Created by Nikhil Konkimalla on 10/12/25.
//

import Foundation
import Vision
import UIKit

class MLVerificationService {
    static let shared = MLVerificationService()
    
    private init() {}
    
    func verifyTask(_ task: AlarmTask, in image: UIImage) async throws -> Bool {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "MLVerificationService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            // Use VNClassifyImageRequest instead of VNRecognizeObjectsRequest for better compatibility
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: false)
                    return
                }
                
                // Get top classifications with confidence > 0.5
                let topClassifications = observations
                    .filter { $0.confidence > 0.5 }
                    .map { $0.identifier.lowercased() }
                
                // Check if any detected object matches the task's verification objects
                let requiredObjects = task.verificationObjects.map { $0.lowercased() }
                
                let isVerified = topClassifications.contains { detectedObject in
                    requiredObjects.contains { requiredObject in
                        detectedObject.contains(requiredObject) || requiredObject.contains(detectedObject)
                    }
                }
                
                continuation.resume(returning: isVerified)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

