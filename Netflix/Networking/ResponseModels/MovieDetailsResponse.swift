//
//  MovieDetailsResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation

struct MovieDetailsResponse: Codable {
    let id: Int
    let overview: String
    let poster_path: String?
    let release_date: String
    let runtime: Int
    let title: String
    let video: Bool
    let vote_average: Float
}
