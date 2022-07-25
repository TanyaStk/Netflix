//
//  SearchResultResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation

struct SearchResultResponse: Codable {
    let page: Int
    let results: [MovieResponse]
}
