//
//  ViewModel.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import UIKit
import Combine

class ViewModel {
    private let callManager: CallManager
    private let userService: UserService

    private var cancellables: Set<AnyCancellable> = []

    init() {
        callManager = CallManagerImplemented()
        userService = UserServiceImplemented()

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
}
