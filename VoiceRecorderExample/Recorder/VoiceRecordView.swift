import UIKit
import AVFoundation
import QuartzCore

class VoiceRecordView: UIView, AVAudioPlayerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recordBtnBack: RedRecordBtnBack!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var audioPlot: SoundWaveVisualizer!
    @IBOutlet weak var timeLabel: UILabel!
    
    enum State {
        case idle, record, play
    }
    
    var state = State.idle
    
    var player: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    
    var displaylink: CADisplayLink!
    
    var audioFileUrl: URL {
        let url = FileManager.fileUrlInsideCacheDir("voice_message.mp4")
        
        return url
    }
    
    // Callbacks
    
    var voiceSavedAction:((_ soundFileData: Data?, _ sizeInBytes: Int)->Void)?
    
    class func createFromNib() -> VoiceRecordView {
        let view = Bundle.main.loadNibNamed("VoiceRecordView", owner: nil, options: [:])?.last! as! VoiceRecordView
        
        view.titleLabel.text = L("Record Voice").uppercased()
        
        view.sendBtn.setTitle(L("Save"), for: .normal)
        
        view.setupAudioSession()
        
        view.hideMessageControls()
        
        view.fixBundleImagesLoading()
        
        return view
    }
    
    // Images from custom bundle rendered in storyboard, but does not loaded on device
    fileprivate func fixBundleImagesLoading() {
        playBtn.setImage(UIImage(named: "RecorderResources.bundle/ic_play_btn.png"), for: .normal)
        playBtn.setImage(UIImage(named: "RecorderResources.bundle/ic_pause_btn.png"), for: .selected)
    }
    
    fileprivate func setupAudioSession() {
        audioPlot.backgroundColor = UIColor.clear
        
        let recoderSettings: [String: AnyObject] = [
            AVSampleRateKey:          44100.0 as AnyObject,
            AVFormatIDKey:            NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
            AVNumberOfChannelsKey:    2 as AnyObject,
            AVEncoderAudioQualityKey: NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)
        ]
        
        let session = AVAudioSession.sharedInstance()
        
        session.requestRecordPermission {[weak self] granted in
            guard let this = self else { return }
            
            this.recordBtn.isEnabled = granted
            this.recordBtnBack.isEnabled = granted
            
            if !granted {
                this.titleLabel.text = L("Enable microphone access\nfrom system preferences")
            }
        }
        
        do {
            FileManager.default.createFile(atPath: audioFileUrl.path, contents: nil, attributes: nil)
            
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            try session.overrideOutputAudioPort(.speaker)
            
            recorder = try AVAudioRecorder(url: audioFileUrl, settings: recoderSettings)
            
            displaylink = CADisplayLink(target: self, selector: #selector(updateMeters))
            displaylink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            
        } catch let e {
            print("VoiceRecordView: setup AVAudioSession error", e)
        }
    }
    
    fileprivate func updateTimeLabel(_ timeFormatted: String) {
        ui {[weak self] in
            self?.timeLabel.text = timeFormatted
        }
    }
    
    func startRecord() {
        player?.stop()
        
        state = .record
        
        recorder?.stop()
        recorder?.prepareToRecord()
        recorder?.isMeteringEnabled = true
        recorder?.record()
        
        hideMessageControls()
    }
    
    func stopRecord() {
        let recordTime = recorder?.currentTime ?? 0.0
        
        recorder?.stop()
        
        if recordTime > 2 {
            showMessageControls()
        }
    }
    
    fileprivate func releaseRecorder() {
        recorder?.stop()
        player?.stop()
        
        recorder = nil
        player = nil
        
        displaylink.isPaused = true
        displaylink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
        displaylink.invalidate()
    }
    
    func playRecordedMessage() {
        if player == nil {
            do {
                player = try AVAudioPlayer(contentsOf: audioFileUrl)
                player?.delegate = self
                player?.isMeteringEnabled = true
                player?.prepareToPlay()
            } catch let e {
                print("VoiceRecordView: create AVAudioPlayer error", e)
            }
        }
        
        if let player = player {
            player.stop()
            player.play()
            
            if player.isPlaying {
                state = .play
                playBtn.isSelected = true
            }
        }
    }
    
    func pausePlayback() {
        playBtn.isSelected = false
        player?.stop()
        player?.currentTime = 0
        player = nil
        
        state = .idle
    }
    
    func showMessageControls() {
        playBtn.isHidden = false
        sendBtn.isHidden = false
    }
    
    func hideMessageControls() {
        playBtn.isHidden = true
        sendBtn.isHidden = true
    }
    
    func normalizedPower(_ decibels: Float) -> Float {
        if (decibels < -60.0 || decibels == 0.0) {
            return 0.0
        }
        
        return powf((pow(10.0, 0.05 * decibels) - pow(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - pow(10.0, 0.05 * -60.0))), 1.0 / 2.0)
    }
    
    @objc func updateMeters() {
        var normalizedValue: Float = 0.0
        var time = 0.0
        
        if state == .record {
            if let recorder = recorder {
                recorder.updateMeters()
                let decibels = recorder.averagePower(forChannel: 0)
                
                normalizedValue = normalizedPower(decibels)
                
                time = recorder.currentTime
            }
        }
        
        if state == .play {
            if let player = player {
                player.updateMeters()
                let decibels = player.averagePower(forChannel: 0)
                
                normalizedValue = normalizedPower(decibels)
                
                time = player.currentTime
            }
        }
        
        audioPlot.updateWithPowerLevel(normalizedValue)
        
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        pausePlayback()
    }
    
    @IBAction func recordBtnAction(_ sender: UIButton?) {        
        switch state {
        case .idle:
            recordBtnBack.animateRecord()
            sender?.isSelected = true
            startRecord()
            
        case .record:
            state = .idle
            recordBtnBack.animateStop()
            sender?.isSelected = false
            stopRecord()
            
        case .play:
            pausePlayback()
            break
        }
    }
    
    @IBAction func saveBtnAction(_ sender: AnyObject) {
        if state == .play {
            pausePlayback()
        }
        
        var fileSize = 0
        
        if  FileManager.default.fileExists(atPath: audioFileUrl.path) {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: audioFileUrl.path)
                fileSize = attributes[FileAttributeKey.size] as? Int ?? 0
            } catch let e {
                print("VoiceRecordView: Can not read attributes for sound file", e)
            }
        }
        
        print("VoiceRecordView: Audio file size: \(fileSize) bytes")
        
        var soundFileData: Data?
        if fileSize >= 100000 {
            soundFileData = try? Data(contentsOf: URL(fileURLWithPath: audioFileUrl.path))
        }
        
        voiceSavedAction?(soundFileData, fileSize)
    }
    
    @IBAction func playBtnAction(_ sender: AnyObject) {
        if state == .play {
            pausePlayback()
        } else {
            playRecordedMessage()
        }
    }
}
