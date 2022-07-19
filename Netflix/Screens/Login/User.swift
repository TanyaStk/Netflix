//
//  User.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 09.06.2022.
//

import Foundation

struct User: Codable {
    let login: String
    let password: String
    let request_token: String
    let token_expire_at: String
    let session_id: String
}
