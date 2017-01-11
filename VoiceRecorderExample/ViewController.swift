import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recordView = VoiceRecordView.createFromNib()
        recordView.backgroundColor = UIColor.black
        recordView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordView)
        
        let csH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v]-0-|", options: [], metrics: [:], views: ["v": recordView])
        let csV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v]-0-|", options: [], metrics: [:], views: ["v": recordView])
        
        view.addConstraints(csH)
        view.addConstraints(csV)
        
        recordView.voiceSavedAction = {[weak self] data, size in
            guard let this = self else { return }
            
            this.alertSimple("Recorded", message: "File saved at \(recordView.audioFileUrl).\nFile size is \(size) bytes")
        }
    }

}

