//
//  CallManager.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 18/12/2023.
//

import AgoraRtcKit
import AVFoundation
import CallKit
import Combine
import PushKit
import UIKit

protocol CallManager {
    var statusPublisher: AnyPublisher<String, Error> { get }

    /// Handles joining a going on call (incoming call)
    func joinCall()

    /// Handles starting a call (outgoing call)
    func startCall()

    /// Handles leaving a call
    func leaveCall()
}

class CallManagerImplemented: NSObject, CallManager {
    var statusPublisher: AnyPublisher<String, Error> {
        status.eraseToAnyPublisher()
    }

    private var status = PassthroughSubject<String, Error>()

    private var configuration: CXProviderConfiguration?
    private var provider: CXProvider?
    private var controller: CXCallController?

    // The main entry point for Video SDK
    private var agoraEngine: AgoraRtcEngineKit!
    // By default, set the current user role to broadcaster to both send and receive streams.
    private var userRole: AgoraClientRole = .broadcaster

    // TODO: Move this credentials to another place
    // Update with the App ID of your project generated on Agora Console.
    private let appID = "5e4ccb78bc6f451bbe3c5c56eb033d99"
    // Update with the temporary token generated in Agora Console.
    private var token = "007eJxTYPCYHqCZceTR7DcpbK61t1xOye8S2nDh+6lnIod1NeYyXn2gwGCaapKcnGRukZRslmZiapiUlGqcbJpsapaaZGBsnGJp6fijMrUhkJFh3uUnjIwMEAjiszGkpObm61YwMAAAEE0ijQ=="
    // Update with the channel name you used to generate the token in Agora Console.
    private var channelName = "demo-x"

    // Track if the local user is in a call
    var joined: Bool = false {
        didSet {
            status.send(joined ? "Joined the call" : "Not in the call")
        }
    }

    override init() {
        super.init()

        /// CallKit setup
        configuration = CXProviderConfiguration()
//        configuration?.supportsVideo = true // supporting video calls
//        configuration?.ringtoneSound = "" // customizing ringtone sound
        configuration?.includesCallsInRecents = true

        provider = CXProvider(configuration: configuration!)
        provider?.setDelegate(self, queue: nil)

        /// PushKit setup
        let registry = PKPushRegistry(queue: nil)
        registry.delegate = self
        registry.desiredPushTypes = [PKPushType.voIP]

        /// Agora setup
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = appID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }
}

// MARK: - Calls

extension CallManagerImplemented {
    func joinCall() {
        let option = AgoraRtcChannelMediaOptions()

        // Set the client role option as broadcaster or audience.
        if userRole == .broadcaster {
            option.clientRoleType = .broadcaster
        } else {
            option.clientRoleType = .audience
        }

        // For an audio call scenario, set the channel profile as communication.
        option.channelProfile = .communication

        // Join the channel with a temp token and channel name
        let result = agoraEngine.joinChannel(
            byToken: token, channelId: channelName, uid: 0, mediaOptions: option,
            joinSuccess: { _, _, _ in }
        )

        // Check if joining the channel was successful and set joined Bool accordingly
        if result == 0 {
            joined = true
            status.send("Successfully joined the channel as \(userRole)")
        }
    }

    func leaveCall() {
        let result = agoraEngine.leaveChannel(nil)
        // Check if leaving the channel was successful and set joined Bool accordingly
        if result == 0 { joined = false }
    }

    /// - Handling an outgoing call
    func startCall() {
        controller = CXCallController()
        let transaction = CXTransaction(action: CXStartCallAction(call: UUID(), handle: CXHandle(type: .generic, value: "Mehmet Outgoing")))
        controller?.request(transaction, completion: { _ in })
    }

    /// - Connecting an outgoing call
    private func connectCall() {
        guard let controller,
              !controller.callObserver.calls.isEmpty else { return }
        provider?.reportOutgoingCall(with: controller.callObserver.calls[0].uuid, connectedAt: nil)
    }
}

// MARK: - CXProviderDelegate

extension CallManagerImplemented: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        status.send("providerDidReset")
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        status.send("\(#function) - CXAnswerCallAction")
        action.fulfill()
        joinCall()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // TODO: Handle leaveCall(_:)
        status.send("\(#function) - CXEndCallAction")
        action.fulfill()
    }
}

// MARK: - PKPushRegistryDelegate

extension CallManagerImplemented: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
        status.send(token)
    }

    // MARK: A call is received via notifications

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // TODO: Apply serialization with Codable protocol
        guard let data = payload.dictionaryPayload as? [String: Any],
              let aps = data["aps"] as? [String: Any] else { return }

        guard let from = aps["from"] as? String else { return }
//        guard let from = aps["from"] as? String,
//              let type = aps["type"] as? String else { return }
//
//        var handleType = CXHandle.HandleType.generic
//
//        switch type {
//        case "phoneNumber":
//            handleType = .phoneNumber
//        case "emailAddress":
//            handleType = .emailAddress
//        default:
//            handleType = .generic
//        }

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: from)
//        update.hasVideo = true
        provider?.reportNewIncomingCall(with: UUID(), update: update, completion: { _ in })
    }
}

// MARK: - AgoraRtcEngineDelegate

extension CallManagerImplemented: AgoraRtcEngineDelegate {
    // Callback called when a new host joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
    }
}
