//
//  URL+.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import Foundation

extension URL {
    struct Push {
        static func new() -> URL? {
            URL(string: "\(BaseURL.shared)/push")
        }
    }
}
