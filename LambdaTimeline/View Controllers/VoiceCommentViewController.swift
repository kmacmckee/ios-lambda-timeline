//
//  VoiceCommentViewController.swift
//  LambdaTimeline
//
//  Created by Kobe McKee on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceCommentViewController: UIViewController, AVAudioRecorderDelegate {

    var post: Post?
    var postController: PostController?
    private var recorder: AVAudioRecorder?
    var recordingURL: URL?
    
    var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    @IBOutlet weak var recordButton: UIButton!
    
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        
        if isRecording {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.record()
            recorder?.delegate = self
        } catch {
            NSLog("Error starting the recording: \(error)")
        }
        
        updateButtons()
        
    }
    
    func newRecordingURL() -> URL {
        let directory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    func updateButtons() {
        let recordButtonTitle = isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        updateButtons()
        recordingURL = recorder.url
        print(recordingURL?.absoluteString)
    }
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        guard let recordingURL = recordingURL else {
            print("Recording URL not found")
            return
        }
        guard var post = post else { return }
        
        postController?.addVoiceComment(audioURL: recordingURL, post: &post)
        print("voiceComment submitted")
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
}
