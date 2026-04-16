//
//  AngleCalculator.swift
//  Testing
//
//  Created by Yashika Sharma on 06/04/26.
//

import CoreGraphics

class AngleCalculator {
    
    static func angle(a: CGPoint, b: CGPoint, c: CGPoint) -> CGFloat {
        let ab = CGVector(dx: a.x - b.x, dy: a.y - b.y)
        let cb = CGVector(dx: c.x - b.x, dy: c.y - b.y)
        
        let dot = ab.dx * cb.dx + ab.dy * cb.dy
        let magAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy)
        let magCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy)
        
        return acos(dot / (magAB * magCB)) * 180 / .pi
    }
}
