//
//  NetworkingError.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 01.07.2022.
//

import Foundation

enum NetworkingError: Error {
    
    case invalidAPIKey
    case resourceCouldNotBeFound
    case unknown
    case with(message: String)
    
    init(message: String) {
        switch message {
        case "Invalid API key: You must be granted a valid key.":
            self = .invalidAPIKey
        case "The resource you requested could not be found.":
            self = .resourceCouldNotBeFound
        default: self = message.isEmpty ? .unknown: .with(message: message)
        }
    }
}
