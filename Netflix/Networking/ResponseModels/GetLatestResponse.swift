//
//  GetLatestResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation

struct GetLatestResponse: Codable {
    let adult: Bool
    let genres: [Genre]
    let id: Int
    let poster_path: String?
    let title: String
}

struct Genre: Codable {
    let id: Int
    let name: String
}
