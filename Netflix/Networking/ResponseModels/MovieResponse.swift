//
//  MovieResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation

struct MovieResponse: Codable {
    let id: Int
    let poster_path: String?
    let overview: String
    let release_date: String
    let title: String
    let vote_average: Float
}
