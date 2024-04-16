//
//  VideoCallCollectionItemCell.swift
//  Awesome Video Call
//

import AgoraRtcKit
import UIKit

final class VideoCallCollectionItemCell: UICollectionViewCell {
    
    func configure(with uid: UInt, agoraRTCEngine: AgoraRtcEngineKit) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = self
        agoraRTCEngine.setupRemoteVideo(videoCanvas)
    }
}
