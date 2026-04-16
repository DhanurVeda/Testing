//
//  VideoExporter.swift
//  Testing
//
//  Created by Yashika Sharma on 06/04/26.
//


import AVFoundation
import UIKit

class VideoExporter {
    
    func export(images: [UIImage], outputURL: URL, completion: @escaping () -> Void) {
        
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let first = images.first else { return }
        
        let width = Int(first.size.width)
        let height = Int(first.size.height)
        
        let writer = try! AVAssetWriter(outputURL: outputURL, fileType: .mov)
        
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        input.expectsMediaDataInRealTime = false
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input)
        
        writer.add(input)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        let queue = DispatchQueue(label: "videoQueue")
        var frame: Int64 = 0
        
        input.requestMediaDataWhenReady(on: queue) {
            while input.isReadyForMoreMediaData && frame < Int64(images.count) {
                
                let img = images[Int(frame)]
                
                if let buffer = self.pixelBuffer(from: img) {
                    let time = CMTime(value: frame, timescale: 30)
                    adaptor.append(buffer, withPresentationTime: time)
                }
                
                frame += 1
            }
            
            if frame >= Int64(images.count) {
                input.markAsFinished()
                writer.finishWriting {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    private func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var buffer: CVPixelBuffer?
        
        CVPixelBufferCreate(nil, width, height,
                            kCVPixelFormatType_32ARGB,
                            nil, &buffer)
        
        guard let px = buffer else { return nil }
        
        CVPixelBufferLockBaseAddress(px, [])
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(px),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(px),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        CVPixelBufferUnlockBaseAddress(px, [])
        
        return px
    }
}
