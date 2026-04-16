import UIKit

class FrameRenderer {
    
    func drawTPosture(
        leftShoulder: CGPoint,
        rightShoulder: CGPoint,
        elbow: CGPoint,
        on image: UIImage
    ) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { ctx in
            image.draw(at: .zero)
            
            let cg = ctx.cgContext
            cg.setLineWidth(6)
            
            // MARK: - Shoulder Analysis
            let dy = abs(leftShoulder.y - rightShoulder.y)
            
            let shoulderColor: UIColor
            let shoulderText: String
            
            if dy < 20 {
                shoulderColor = .green
                shoulderText = "Good"
            } else if dy < 50 {
                shoulderColor = .yellow
                shoulderText = "Almost"
            } else {
                shoulderColor = .red
                shoulderText = "Fix"
            }
            
            // MARK: - Elbow Analysis
            let midY = (leftShoulder.y + rightShoulder.y) / 2
            let elbowDiff = abs(elbow.y - midY)
            
            let elbowColor: UIColor
            let elbowText: String
            
            if elbowDiff < 25 {
                elbowColor = .green
                elbowText = "Good"
            } else if elbowDiff < 60 {
                elbowColor = .yellow
                elbowText = "Almost"
            } else {
                elbowColor = .red
                elbowText = "Fix"
            }
            
            // MARK: - Draw Shoulder Line
            cg.setStrokeColor(shoulderColor.cgColor)
            cg.move(to: leftShoulder)
            cg.addLine(to: rightShoulder)
            cg.strokePath()
            
            // MARK: - Draw Arm Line
            cg.setStrokeColor(elbowColor.cgColor)
            cg.move(to: rightShoulder)
            cg.addLine(to: elbow)
            cg.strokePath()
            
            // MARK: - Draw Joints
            for point in [leftShoulder, rightShoulder, elbow] {
                let rect = CGRect(x: point.x - 6, y: point.y - 6, width: 12, height: 12)
                cg.setFillColor(UIColor.white.cgColor)
                cg.fillEllipse(in: rect)
            }
            
            // MARK: - Feedback Text
            let feedback = """
            Shoulders: \(shoulderText)
            Elbow: \(elbowText)
            """
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 36),
                .foregroundColor: UIColor.white,
                .backgroundColor: UIColor.black.withAlphaComponent(0.6)
            ]
            
            feedback.draw(at: CGPoint(x: 30, y: 40), withAttributes: attributes)
        }
    }
}
