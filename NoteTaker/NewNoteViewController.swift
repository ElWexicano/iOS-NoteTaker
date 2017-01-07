//
//  NewNoteViewController.swift
//  NoteTaker
//
//  Created by Shane Doyle on 07/01/2017.
//  Copyright © 2017 Shane Doyle. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    var audioURL : String = ""
    var audioRecorder : AVAudioRecorder!
    
    override func viewDidLoad() {

        super.viewDidLoad()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func record(_ sender: Any) {
    }
    
}
