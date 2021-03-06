//
//  NoteTakerViewController.swift
//  NoteTaker
//
//  Created by Shane Doyle on 19/12/2016.
//  Copyright © 2016 Shane Doyle. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NoteTakerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var notesArray: [Note] = []
    
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 57
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<Note>(entityName: "Note")
        
        self.notesArray = try! context.fetch(request)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sound = notesArray[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel!.text = sound.name
        
        let font = UIFont(name: "Avenir-Book", size: 16)
        let color = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.4)
        cell.textLabel?.font = font
        cell.textLabel?.textColor = color
        
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
        
        let sound = notesArray[indexPath.row]
        let baseString : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let pathComponents = [baseString, sound.url]
        let audioNSURL = NSURL.fileURL(withPathComponents: pathComponents)!
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            self.audioPlayer = try AVAudioPlayer(contentsOf: audioNSURL)
        } catch let initError as NSError {
            print("Init error: \(initError.localizedDescription)")
        }
        
        self.audioPlayer.play()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let section = indexPath.section
        let numberOfRows = tableView.numberOfRows(inSection: section)
        
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRow(at: NSIndexPath(row: row, section: section) as IndexPath) {
                let image : UIImage = UIImage(named: "checkmark")!
                cell.imageView!.image = image
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(notesArray[indexPath.row] as NSManagedObject)
            notesArray.remove(at: indexPath.row)
            
            do {
                try context.save()
                
            } catch let error as NSError {
                print("Whit son, we've got an error: \(error.localizedDescription)")
            }
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
        default:
            return
        }
        
    }
}
