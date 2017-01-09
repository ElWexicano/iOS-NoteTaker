//
//  NewNoteViewController.swift
//  NoteTaker
//
//  Created by Shane Doyle on 07/01/2017.
//  Copyright © 2017 Shane Doyle. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NewNoteViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        let baseString : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        self.audioURL = NSUUID().uuidString + ".m4a"
        let pathComponents = [baseString, self.audioURL]
        let audioNSURL = NSURL.fileURL(withPathComponents: pathComponents)!
        let session = AVAudioSession.sharedInstance()
        
        let recordSettings : [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 2 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            self.audioRecorder = try AVAudioRecorder(url: audioNSURL, settings: recordSettings)
        } catch let initError as NSError {
            print("Init error: \(initError.localizedDescription)")
        }
        
        self.audioRecorder.isMeteringEnabled = true
        self.audioRecorder.prepareToRecord()
        
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var peakLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressView2: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var audioURL : String = ""
    var audioRecorder : AVAudioRecorder!
    var timerInterval : TimeInterval = 0.5
    var audioPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.layer.shadowOpacity = 1.0
        recordButton.layer.shadowOffset = CGSize(width: 5.0, height: 4.0)
        recordButton.layer.shadowRadius = 5.0
        recordButton.layer.shadowColor = UIColor.black.cgColor
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        if (noteTitle.text != "") {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
        
            note.name = noteTitle.text!
            note.url = audioURL
        
            do {
                try context.save()
            } catch let saveError as NSError {
                print("Save error: \(saveError.localizedDescription)")
            }
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func record(_ sender: Any) {
        
        let mic = UIImage(named: "microphoneDepressed.png") as UIImage!
        recordButton.setImage(mic, for: .normal)
        
        recordButton.layer.shadowOpacity = 1.0
        recordButton.layer.shadowOffset = CGSize(width: 5.0, height: 4.0)
        recordButton.layer.shadowRadius = 5.0
        recordButton.layer.shadowColor = UIColor.black.cgColor
        
        if (audioRecorder.isRecording) {
            let mic = UIImage(named: "microphone.png") as UIImage!
            recordButton.setImage(mic, for: .normal)
            
            audioRecorder.stop()
        } else {
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.setActive(true)
                audioRecorder.record()
            } catch let recordError as NSError {
                print("Record error: \(recordError.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func touchDownRecord(_ sender: Any) {
        
        audioPlayer = getAudioPlayerFile(file: "beep1", type: "mp3")
        audioPlayer.play()
        
        let timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.updateAudioMeter), userInfo: nil, repeats: true)
        
        timer.fire()
        
        recordButton.layer.shadowOpacity = 1.0
        recordButton.layer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        recordButton.layer.shadowRadius = 1.0
        recordButton.layer.shadowColor = UIColor.black.cgColor
    }
    
    func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            
            let dFormat = "%02d"
            let min:Int = Int(audioRecorder.currentTime / 60)
            let sec:Int = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let timeString = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            timeLabel.text = timeString
            audioRecorder.updateMeters()
            
            let averageAudio = audioRecorder.averagePower(forChannel: 0) * -1
            let peakAudio = audioRecorder.peakPower(forChannel: 0) * -1
            let progressViewAverage = Int(averageAudio)
            let progressViewPeak = Int(peakAudio)
            
            progressLabel.text = "\(averageAudio)%"
            peakLabel.text = "\(peakAudio)%"
            
            bar(progressBar1: progressViewAverage, progressBar2: progressViewPeak)
            
        } else {
            progressView.setProgress(0.0, animated: true)
            progressView2.setProgress(0.0, animated: true)
            progressLabel.text = "0%"
            peakLabel.text = "0%"
        }
    }
    
    func bar(progressBar1: Int, progressBar2: Int) {
        // TODO add in the updating of the progress bars. Seems like a lot of switching for my liking.
    }
    
    func getAudioPlayerFile(file: String, type: String) -> AVAudioPlayer {
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = NSURL.fileURL(withPath: path!)
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch let audioPlayerError as NSError {
            print("Failed to initialise audio player error: \(audioPlayerError.localizedDescription)")
        }
        
        return audioPlayer!
    }
    
}
