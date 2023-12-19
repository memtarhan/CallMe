//
//  PeopleData.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import Foundation

struct Person: Identifiable {
    let id: String
    let deviceName: String
    let deviceType: String
    let deviceRegion: String?
    let deviceToken: String
    
    static let sample = Person(id: "identifier", deviceName: "iPhone 12", deviceType: "iPhone", deviceRegion: "PT", deviceToken: "deviceToken")
}

@MainActor
class PeopleData: ObservableObject {
    @Published var people = [Person]()
    
    private let userService: UserService
    
    init() {
        self.userService = UserServiceImplemented()
    }
    
    func load() {
        userService.retrieveUsers { person in
            self.people.append(person)
        }
    }
}
