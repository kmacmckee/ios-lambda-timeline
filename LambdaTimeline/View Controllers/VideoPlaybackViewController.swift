//
//  VideoPlaybackViewController.swift
//  LambdaTimeline
//
//  Created by Kobe McKee on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlaybackViewController: UIViewController {

    var recording: AVCaptureMovieFileOutput?
    var postController: PostController?
    
    
    @IBOutlet weak var playbackView: VideoPlaybackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayback()
    }
    
    
    private func setupPlayback() {
        guard let url = recording?.outputFileURL else { return }
        
        let player = AVPlayer(url: url)
        
        playbackView.videoPlaybackLayer.player = player
        player.play()
    }
    

    @IBAction func saveButtonPressed(_ sender: Any) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
