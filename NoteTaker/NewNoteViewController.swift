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
    
    var audioURL : String = ""
    var audioRecorder : AVAudioRecorder!
    
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
        
        recordButton.layer.shadowOpacity = 1.0
        recordButton.layer.shadowOffset = CGSize(width: 5.0, height: 4.0)
        recordButton.layer.shadowRadius = 5.0
        recordButton.layer.shadowColor = UIColor.black.cgColor
        
        if (audioRecorder.isRecording) {
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
        recordButton.layer.shadowOpacity = 1.0
        recordButton.layer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        recordButton.layer.shadowRadius = 1.0
        recordButton.layer.shadowColor = UIColor.black.cgColor
    }
    
    
    
    
}
