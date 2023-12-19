//
//  ViewController.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 18/12/2023.
//

import AVFoundation
import Combine
import SwiftUI
import UIKit

class ViewController: UIViewController {
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var textView: UITextView!

    private var viewModel: ViewModel!

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = ViewModel()

        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Task {
            if await !checkForPermissions() {
                statusLabel.text = "Permissions were not granted"
            }
        }

//        testStartingACall()
    }

//    func testStartingACall() {
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//            self.manager.startCall()
//        })
//    }
//
//    func testJoiningACall() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//            self.manager.joinCall()
//        })
//    }

    func checkForPermissions() async -> Bool {
        let hasPermissions = await avAuthorization(mediaType: .audio)
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
}

private extension ViewController {
    func setup() {
        let peopleView = PeopleListView { person in
            // TODO: Trigger phone call
            print(person.id)
        }

        let config = UIHostingConfiguration {
            peopleView
        }
        let peopleSubview = config.makeContentView()

        peopleSubview.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(peopleSubview)

        NSLayoutConstraint.activate([
            peopleSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            peopleSubview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            peopleSubview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            peopleSubview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

//        manager.statusPublisher
//            .receive(on: RunLoop.main)
//            .sink { completion in
//                switch completion {
//                case .finished:
//                    // Handle finished state
//                    break
//                case let .failure(error):
//                    // Handle error state
//                    print(error.localizedDescription)
//                    break
//                }
//            } receiveValue: { status in
//                self.statusLabel.text = status
//                self.textView.text = status
//            }
//            .store(in: &cancellables)
    }
}
