import Foundation
import UIKit

extension UIColor {
    class func colorWithHexString (_ hex:String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased();
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    class func defaultTintColor() -> UIColor {
        // #007AFF
        return UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    }
}

extension FileManager {
    class var cachesUrl: URL {
        get {
            return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
        }
    }
    
    class func fileUrlInsideCacheDir(_ fileName: String) -> URL {
        return cachesUrl.appendingPathComponent(fileName)
    }
}

func future(_ closure:@escaping ()->()) {
    let backQueue = DispatchQueue(label: "future", attributes: .concurrent)
    backQueue.async(execute: closure)
}

func delayCall(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func ui(_ closure:@escaping ()->()){
    DispatchQueue.main.async(execute: closure)
}

extension UIViewController {
    
    func alertSimple(_ title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L("Close"), style: .cancel, handler: { a in}))
        present(alert, animated: true, completion: nil)
    }    
}

/// NSLocalizedString shortcut
func L(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}
