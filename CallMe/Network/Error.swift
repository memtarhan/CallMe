//
//  Error.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import Foundation

protocol CMError: Error, CustomStringConvertible {}

enum HTTPError: CMError {
    case failed
    case invalidEndpoint
    case invalidData
}

extension HTTPError {
    var description: String {
        switch self {
        case .failed:
            return "Failed to connect"
        case .invalidEndpoint:
            return "Invalid endpoint"
        case .invalidData:
            return "Invalid data"
        }
    }
}
