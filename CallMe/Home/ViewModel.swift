//
//  ViewModel.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import Combine
import UIKit

class ViewModel {
    private let callService: CallService
    private let callManager: CallManager
    private let userService: UserService

    private var cancellables: Set<AnyCancellable> = []

    var statusPublisher: AnyPublisher<String, Error>?

    init() {
        callService = CallServiceImplemented()
        callManager = CallManagerImplemented()
        userService = UserServiceImplemented()

        statusPublisher = callManager.statusPublisher.eraseToAnyPublisher()

        callManager.tokenPublisher
            .sink { _ in

            } receiveValue: { token in
                guard let identifier = UIDevice.current.identifierForVendor?.uuidString else { return }
                let deviceName = UIDevice.current.name
                let deviceType = UIDevice.current.model
                let deviceRegion = Locale.current.region?.identifier

                self.userService.saveUser(identifier: identifier, deviceName: deviceName, deviceType: deviceType, deviceRegion: deviceRegion, deviceToken: token)
                print(token)
            }
            .store(in: &cancellables)
    }

    func startPhoneCall(withPerson person: Person) {
        Task(priority: .background) {
            // TODO: Handle error with try/catch
            try? await self.callService.sendCallNotification(to: person.deviceToken)
        }

        // TODO: Implement dynamic channels, there's only 1 static channel for testing purposes
        callManager.joinCall()
    }
}
