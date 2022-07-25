//
//  MoviesList.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation

struct MoviesListResponse: Codable {
    let page: Int
    let number_of_pages: Int
    let movies: [MovieResponse]
}
