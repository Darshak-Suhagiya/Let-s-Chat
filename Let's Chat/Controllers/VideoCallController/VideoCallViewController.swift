//
//  VideoCallViewController.swift
//  Let-s Chat
//
//  Created by DUIUX - 01 on 16/05/23.
//

import UIKit
import AgoraRtcKit
import AVFoundation
import PythonKit


class VideoCallViewController: UIViewController {
    
    
    @IBOutlet weak var localContainer: UIView!
    @IBOutlet weak var remoteContainer: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    
    var joinButton: UIButton!
    var agoraEngine: AgoraRtcEngineKit!
    // By default, set the current user role to broadcaster to both send and receive streams.
    var userRole: AgoraClientRole = .broadcaster
    
    // Update with the App ID of your project generated on Agora Console.
    let appID = "60a88ba3021f40ef858b34467963a11b"
    let agoraAppCertificate = "4b2d2a132e554349a5902f43d2c453e9"
    // Update with the temporary token generated in Agora Console.
    var token = ""
    // Update with the channel name you used to generate the token in Agora Console.
    var channelName = ""
    
    var joined: Bool = false {
        didSet {
            DispatchQueue.main.async {
                
//               0 self.joinButton.setTitle( self.joined ? "Leave" : "Join", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The following functions are used when calling Agora APIs
        initializeAgoraEngine()
        
//        Task {
//            await joinChannel()
//        }
        runPythonCode()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        leaveChannel()
        DispatchQueue.global(qos: .userInitiated).async {AgoraRtcEngineKit.destroy()}
    }
    
    func runPythonCode() {
        
//        let pythonLibraryPath = "/path/to/python3 --config"
//
//        // Set PYTHON_LIBRARY environment variable
//        setenv("PYTHON_LIBRARY", pythonLibraryPath, 1)
        
        unsetenv("PYTHON_LIBRARY")
        
        let python = Python.import("src.RtcTokenBuilder2")  // Replace with your Python file name without the extension

        let appId = "60a88ba3021f40ef858b34467963a11b"
        let appCertificate = "4b2d2a132e554349a5902f43d2c453e9"
        let channelName = "Your"
        let uid = 0
        let expirationTimeInSeconds = 3600

        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let expiredTs = currentTimestamp + expirationTimeInSeconds

        print("UID token:")
        
        let token = python.RtcTokenBuilder.build_token_with_uid(appId, appCertificate, channelName, uid, python.Role_Publisher, token_expire: expiredTs, privilege_expire: expiredTs)
        print(token)
        
        // Reset PYTHON_LIBRARY environment variable (optional)
        unsetenv("PYTHON_LIBRARY")
    }

    
    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = appID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }
    
    func genrateRTCToken() {

    }
    
    func checkForPermissions() async -> Bool {
        var hasPermissions = await self.avAuthorization(mediaType: .video)
        // Break out, because camera permissions have been denied or restricted.
        if !hasPermissions { return false }
        hasPermissions = await self.avAuthorization(mediaType: .audio)
        return hasPermissions
    }
    
    func avAuthorization(mediaType: AVMediaType) async -> Bool {
        let mediaAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch mediaAuthorizationStatus {
        case .denied, .restricted: return false
        case .authorized: return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default: return false
        }
    }
    
    func showMessage(title: String, text: String, delay: Int = 2) -> Void {
        let deadlineTime = DispatchTime.now() + .seconds(delay)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            self.present(alert, animated: true)
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    func setupLocalVideo() {
        // Enable the video module
        agoraEngine.enableVideo()
        // Start the local video preview
        agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localContainer
        // Set the local video view
        agoraEngine.setupLocalVideo(videoCanvas)
    }
    
    func joinChannel() async {
        if await !self.checkForPermissions() {
            showMessage(title: "Error", text: "Permissions were not granted")
            return
        }
        
        let option = AgoraRtcChannelMediaOptions()
        
        // Set the client role option as broadcaster or audience.
        if self.userRole == .broadcaster {
            option.clientRoleType = .broadcaster
            setupLocalVideo()
        } else {
            option.clientRoleType = .audience
        }
        
        // For a video call scenario, set the channel profile as communication.
        option.channelProfile = .communication
        
        // Join the channel with a temp token. Pass in your token and channel name here
        let result = agoraEngine.joinChannel(
            byToken: token, channelId: channelName, uid: 0, mediaOptions: option,
            joinSuccess: { (channel, uid, elapsed) in }
        )
        // Check if joining the channel was successful and set joined Bool accordingly
        if result == 0 {
            joined = true
            showMessage(title: "Success", text: "Successfully joined the channel as \(self.userRole)")
        }
    }
    
    func leaveChannel() {
        agoraEngine.stopPreview()
        let result = agoraEngine.leaveChannel(nil)
        // Check if leaving the channel was successful and set joined Bool accordingly
        if result == 0 { joined = false }
    }
    
}


extension VideoCallViewController: AgoraRtcEngineDelegate {
    // Callback called when a new host joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteContainer
        agoraEngine.setupRemoteVideo(videoCanvas)
    }
}
