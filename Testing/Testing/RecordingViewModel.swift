import SwiftUI
import AVFoundation
import Vision

@Observable
class RecordingViewModel {
    
    // MARK: - Managers
    let camera = CameraManager()
    let renderer = FrameRenderer()
    
    // MARK: - State
    var isRecording = false
    var outputURL: URL?
    var feedback: String = ""
    
    // MARK: - Video URL
    private var videoURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("recorded.mov")
    }
    
    // MARK: - Setup
    func setup() {
        camera.setup()
    }
    
    // MARK: - Recording
    func startRecording() {
        isRecording = true
        
        try? FileManager.default.removeItem(at: videoURL)
        camera.startRecording(url: videoURL)
    }
    
    func stopRecording() {
        isRecording = false
        camera.stopRecording()
        
        // wait for recording to finish saving
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.processVideo()
        }
    }
    
    // MARK: - Processing Video
    func processVideo() {
        
        print("🎬 Processing started")
        
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.maximumSize = CGSize(width: 720, height: 1280)
        var images: [UIImage] = []
        
        let duration = asset.duration.seconds
        let times = stride(from: 0.0, to: duration, by: 0.4).map {
            CMTime(seconds: $0, preferredTimescale: 600)
        }
        
        for time in times {
            guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else {
                continue
            }
            
            let image = UIImage(cgImage: cgImage)
            
            // MARK: - Vision Pose Detection
            let request = VNDetectHumanBodyPoseRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
            try? handler.perform([request])
            
            guard let observation = request.results?.first else { continue }
            guard let points = try? observation.recognizedPoints(.all) else { continue }
            
            // MARK: - Get joints (T posture)
            guard let leftShoulder = points[.leftShoulder],
                  let rightShoulder = points[.rightShoulder],
                  let rightElbow = points[.rightElbow],
                  leftShoulder.confidence > 0.5,
                  rightShoulder.confidence > 0.5,
                  rightElbow.confidence > 0.5 else {
                continue
            }
            
            // Convert coordinates
            let ls = CGPoint(
                x: leftShoulder.location.x * image.size.width,
                y: (1 - leftShoulder.location.y) * image.size.height
            )
            
            let rs = CGPoint(
                x: rightShoulder.location.x * image.size.width,
                y: (1 - rightShoulder.location.y) * image.size.height
            )
            
            let e = CGPoint(
                x: rightElbow.location.x * image.size.width,
                y: (1 - rightElbow.location.y) * image.size.height
            )
            
            // 🔥 ONLY ONE DRAW CALL
            let processed = renderer.drawTPosture(
                leftShoulder: ls,
                rightShoulder: rs,
                elbow: e,
                on: image
            )
            
            images.append(processed)
        }
        
        print("✅ Frames processed:", images.count)
        
        guard images.count > 0 else {
            DispatchQueue.main.async {
                self.feedback = "❌ No body detected"
            }
            return
        }
        
        // MARK: - Export
        let output = FileManager.default.temporaryDirectory.appendingPathComponent("processed.mov")
        
        let exporter = VideoExporter()
        
        exporter.export(images: images, outputURL: output) {
            
            let exists = FileManager.default.fileExists(atPath: output.path)
            print("📁 File exists:", exists)
            
            DispatchQueue.main.async {
                self.outputURL = output
                self.feedback = "✅ T posture analysis ready"
            }
        }
    }
}
