//
//  CreateSessionResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 29.06.2022.
//

import Foundation

struct CreateSessionResponse: Codable {
    let success: Bool
    let session_id: String
}
