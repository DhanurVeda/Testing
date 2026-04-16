//
//  PoseProcessor.swift
//  Testing
//
//  Created by Yashika Sharma on 06/04/26.
//


import Vision
import UIKit

class PoseProcessor {
    
    func detectPose(in image: CGImage) -> VNHumanBodyPoseObservation? {
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cgImage: image)
        
        do {
            try handler.perform([request])
            return request.results?.first
        } catch {
            print(error)
            return nil
        }
    }
}
