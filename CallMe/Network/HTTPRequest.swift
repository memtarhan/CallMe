//
//  HTTPRequest.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import Foundation

protocol HTTPRequest: Encodable {
    func createURLRequest(withURL url: URL, encoder: JSONEncoder, httpMethod: String) throws -> URLRequest
    func httpBody(withEncoder encoder: JSONEncoder) throws -> Data
}

extension HTTPRequest {
    func createURLRequest(withURL url: URL, encoder: JSONEncoder, httpMethod: String = "POST") throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let httpBody = try encoder.encode(self)
        request.httpBody = httpBody

        return request
    }

    func httpBody(withEncoder encoder: JSONEncoder) throws -> Data {
        try encoder.encode(self)
    }
}

// MARK: - PushNotificationRequest

struct PushNotificationRequest: HTTPRequest {
    let receiverId: String
    let from: String
}
