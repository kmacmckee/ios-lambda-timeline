//
//  VideoPlaybackView.swift
//  LambdaTimeline
//
//  Created by Kobe McKee on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlaybackView: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var videoPlaybackLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    

}
