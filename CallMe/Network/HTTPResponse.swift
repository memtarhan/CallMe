//
//  HTTPResponse.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import Foundation

protocol HTTPResponse: Codable { }

// MARK: - PushNotificationRequest

struct PushNotificationResponse: HTTPResponse {
    let receiverId: String
    let from: String
}
