//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Alan Helal on 10/12/17.
//  Copyright © 2017 Alan Helal. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var stopRecButton: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecButton?.isEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    func setUIStateForRecording(isRecording: Bool) {
        stopRecButton?.isEnabled = isRecording
        recordingButton.isEnabled = !isRecording
    }
    

    @IBAction func recordAudio(_ sender: Any) {
        recordingLabel.text = "Recording in progress..."
        setUIStateForRecording(isRecording: true)
        
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
    }
    
    @IBAction func stopRecordAudio(_ sender: Any) {
        recordingLabel.text = "Tap to record"
        setUIStateForRecording(isRecording: false)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        let alert = UIAlertController(title: "Oooops!", message: "Something went wrong...", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){
            UIAlertAction in NSLog("OK pressed")
        }
        alert.addAction(okAction)
    
        if flag {
            performSegue(withIdentifier: "secondScreen", sender: audioRecorder.url)
        } else {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "secondScreen" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}

