//
//  ErrorResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 01.07.2022.
//

import Foundation

struct NetworkingErrorResponse: Codable {
    let status_message: String
    let status_code: Int
}
