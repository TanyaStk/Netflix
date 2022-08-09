//
//  SearchResultResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation

struct MoviesResultsResponse: Codable {
    let page: Int
    let results: [MovieResponse]
    let total_pages: Int
}
