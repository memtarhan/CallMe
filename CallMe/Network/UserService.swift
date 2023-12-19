//
//  UserService.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import FirebaseDatabase
import Foundation

protocol UserService {
    func saveUser(identifier: String, deviceName: String, deviceType: String, deviceRegion: String?, deviceToken: String)
    func retrieveUsers(_ completion: @escaping (Person) -> Void)
}

class UserServiceImplemented: UserService {
    func saveUser(identifier: String, deviceName: String, deviceType: String, deviceRegion: String?, deviceToken: String) {
        let data = ["identifier": identifier,
                    "deviceName": deviceName,
                    "deviceType": deviceType,
                    "deviceRegion": deviceRegion,
                    "deviceToken": deviceToken]

        Database.database().reference().child("users").child(identifier).setValue(data)
    }

    func retrieveUsers(_ completion: @escaping (Person) -> Void) {
        Database.database().reference().child("users").observe(.childAdded) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                guard let id = data["identifier"] as? String,
                      let deviceName = data["deviceName"] as? String,
                      let deviceType = data["deviceType"] as? String,
                      let deviceToken = data["deviceToken"] as? String else { return }
                let deviceRegion = data["deviceRegion"] as? String
                let person = Person(id: id, deviceName: deviceName, deviceType: deviceType, deviceRegion: deviceRegion, deviceToken: deviceToken)

                completion(person)
            }
        }
    }
}
