//
//  VideoCallViewController.swift
//  Awesome Video Call
//

import AgoraRtcKit
import UIKit

final class VideoCallViewController: UIViewController {

    private var agoraKit: AgoraRtcEngineKit!
    private let token: String
    private let channel: String
    private var collectionViewController: VideoCollectionViewController!
    private let localView = UIView()
    private var collectionView: UIView!
    
    init(token: String, channel: String) {
        self.token = token
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = AgoraRtcEngineConfig()
        // Enter the app ID you obtained from Agora Console
        config.appId = "<#Your app ID#>"
        // Obtain and store reference of the shared engine, passing the config and `self` as delegate
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // Add local view to the screen
        view.addSubview(localView)
        
        // Add collection view that holds remote videos
        collectionViewController = .init(agoraRTCEngine: agoraKit)
        collectionView = collectionViewController.view
        view.addSubview(collectionView)
        addChild(collectionViewController)
        collectionViewController.didMove(toParent: self)
        
        // Add local and remote views to the screen
        setupVideoViews()
        setupLocalVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        joinChannel()
    }
}

// MARK: - AgoraRtcEngineDelegate
extension VideoCallViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        // Occurs when a remote user or user joins the channel.
        collectionViewController.addRemoteVideo(with: uid)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        // Occurs when a remote user or host goes offline.
        collectionViewController.removeRemoteVideo(with: uid)
    }
}

// MARK: - Helpers
private extension VideoCallViewController {
    
    func joinChannel() {
        let option = AgoraRtcChannelMediaOptions()
        // In the video call scenario, set the channel scenario to communication
        option.channelProfile = .communication
        // Set the user role as host
        option.clientRoleType = .broadcaster
        // Use a temporary token to join the channel
        // Pass in your project's token and channel name here.
        agoraKit.joinChannel(
            byToken: token,
            channelId: channel,
            uid: 0,
            mediaOptions: option
        )
    }
    
    func setupVideoViews() {
        
        view.addSubview(localView)
        
        [collectionView, localView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let remoteViewConstraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ]
        
        let localViewConstraints = [
            localView.heightAnchor.constraint(equalTo: localView.widthAnchor, multiplier: 16/9),
            localView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4),
            localView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: localView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(remoteViewConstraints + localViewConstraints)
    }
    
    func setupLocalVideo() {
        // Enable video module
        agoraKit.enableVideo()
        // Start local preview
        agoraKit.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        // Set local view
        agoraKit.setupLocalVideo(videoCanvas)
    }
}
