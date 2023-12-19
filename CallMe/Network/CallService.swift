//
//  CallService.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import Foundation

protocol CallService: NetworkService {
    func sendCallNotification(to receiverId: String) async throws
}

class CallServiceImplemented: CallService {
    func sendCallNotification(to receiverId: String) async throws  {
        guard let url = URL.Push.new() else { throw HTTPError.invalidEndpoint }

        // TODO: Get -from attribute
        let request = PushNotificationRequest(receiverId: receiverId, from: "Mehmet")
        let urlRequest = try request.createURLRequest(withURL: url, encoder: encoder)

        let _: PushNotificationResponse = try await handleDataTask(for: urlRequest)
        
    }
}
