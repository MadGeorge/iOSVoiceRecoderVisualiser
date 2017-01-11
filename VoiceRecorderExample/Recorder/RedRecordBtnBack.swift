import Foundation
import UIKit

class RedRecordBtnBack: UIView, CAAnimationDelegate {
    
    static let buttonMainColor = UIColor.colorWithHexString("FD3B2F")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var isEnabled: Bool = false {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    func animateRecord() {
        let g = animateForm(radiusBig, cRadiusTo: radiusSmall, scaleFrom: 1, scaleTo: 0.53)
        g.delegate = self
        g.setValue("g1", forKey: "id")
        rectLayer.add(g, forKey: "g1")
    }
    
    func animateStop() {
        let g = animateForm(radiusSmall, cRadiusTo: radiusBig, scaleFrom: 0.53, scaleTo: 1)
        g.delegate = self
        g.setValue("g2", forKey: "id")
        rectLayer.add(g, forKey: "g2")
    }
    
    fileprivate var radiusBig: CGFloat {
        return frame.width / 2
    }
    
    fileprivate var radiusSmall: CGFloat {
        return frame.width / 4
    }
    
    let rectLayer = CALayer()
    
    fileprivate func setup() {
        backgroundColor = UIColor.clear
        
        rectLayer.backgroundColor = RedRecordBtnBack.buttonMainColor.cgColor
        rectLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        rectLayer.cornerRadius = radiusBig
        
        layer.addSublayer(rectLayer)
    }
    
    fileprivate func animateForm(_ cRadiusFrom: CGFloat, cRadiusTo: CGFloat, scaleFrom: CGFloat, scaleTo: CGFloat) -> CAAnimationGroup {
        let a1 = CABasicAnimation(keyPath: "cornerRadius")
        a1.fromValue = cRadiusFrom
        a1.toValue = cRadiusTo
        a1.duration = 0.5
        a1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let a2 = CABasicAnimation(keyPath: "transform")
        a2.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(scaleFrom, scaleFrom, 1))
        a2.toValue = NSValue(caTransform3D: CATransform3DMakeScale(scaleTo, scaleTo, 1))
        a2.duration = 0.5
        a2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let g = CAAnimationGroup()
        g.duration = 0.5
        g.animations = [a1, a2]
        g.fillMode = kCAFillModeForwards
        g.isRemovedOnCompletion = false
        
        return g
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let a = anim as? CAAnimationGroup {
            if let _ = a.value(forKey: "id") {
                //animationComplete?()
            }
        }
    }
    
}
