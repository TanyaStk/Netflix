//
//  GetLatestResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation

struct GetLatestResponse: Codable {
    let id: Int
    let title: String
    let poster_path: String
}
