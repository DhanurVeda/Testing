//
//  CameraManager.swift
//  Testing
//
//  Created by Yashika Sharma on 06/04/26.
//
import Combine
import AVFoundation

class CameraManager: NSObject, ObservableObject {
    
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    
    func setup() {
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("❌ Camera not available")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    func startRecording(url: URL) {
        print("🎥 Start recording")
        movieOutput.startRecording(to: url, recordingDelegate: self)
    }
    
    func stopRecording() {
        print("🛑 Stop recording")
        movieOutput.stopRecording()
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        
        if let error = error {
            print("❌ Recording error:", error)
        } else {
            print("✅ Video saved at:", outputFileURL)
        }
    }
}
