//
//  NoteTakerViewController.swift
//  NoteTaker
//
//  Created by Shane Doyle on 19/12/2016.
//  Copyright © 2016 Shane Doyle. All rights reserved.
//

import UIKit
import AVFoundation

class NoteTakerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var notesArray: [Note] = []
    
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = "My First Note"
        return cell
    }
    
    // A file that grabs any audio file path and creates the audio player
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        audioPlayer = getAudioPlayerFile(file: "beep1", type: "mp3")
        audioPlayer.play()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
