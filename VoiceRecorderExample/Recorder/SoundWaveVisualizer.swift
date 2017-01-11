import Foundation
import UIKit

class SoundWaveVisualizer: UIView {
    
    var waveColor = UIColor.white
    var frequency = 1.5
    var amplitude =  1.0
    var idleAmplitude = 0.0
    var numberOfWaves = 4
    var phaseShift = -0.15
    var density: CGFloat = 0.5
    var primaryLineWidth: CGFloat = 0.3
    var secondaryLineWidth: CGFloat = 1.0
    
    var phase = 0.0
    
    func updateWithPowerLevel(_ level: Float) {
        let level = Double(level)
        
        phase = phase + phaseShift
        amplitude = fmax(level, idleAmplitude)
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.clear(self.bounds)
        
        backgroundColor?.set()
        context?.fill(rect)
        
        for i in 0..<numberOfWaves {
            let lineContext = UIGraphicsGetCurrentContext()
            
            lineContext?.setLineWidth((i == 0) ? 2.0 : 1.0)
            
            let halfHeight = rect.height / 2
            let width = rect.width
            let midX = width / 2
            
            let maxAmplitude = halfHeight - 1.0 // 2 corresponds to twice the stroke width
            
            // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
            let progress = 1.0 - Double(i) / Double(numberOfWaves)
            let normalizedAmplitude = (1.5 * progress - 0.5) * amplitude
            
            let right = (progress / 3.0 * 2.0) + (1.0 / 3.0)
            let colorMultiplier = min(1.0, right)
            waveColor.withAlphaComponent(CGFloat(colorMultiplier)).set()
            
            var x: CGFloat = 0
            while x < width {
                
                let scaling = -pow(1 / midX * (x - midX), 2) + 1
                
                let y = scaling * maxAmplitude * CGFloat( normalizedAmplitude * sin(2 * M_PI * Double((x / width)) * frequency + phase) ) + halfHeight

                (x == 0) ? lineContext?.move(to: CGPoint(x: x, y: y)) : lineContext?.addLine(to: CGPoint(x: x, y: y));
                
                x = x + density
            }
            lineContext?.strokePath()
        }
        
    }
}
