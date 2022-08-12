//
//  LatestMovie.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 03.08.2022.
//

import Foundation

struct LatestMovie: Codable {
    let adult: Bool
    let genres: [String]
    let id: Int
    let posterPath: String
    let title: String
    let isFavorite: Bool?
    
    init(adult: Bool, genres: [String], id: Int, imagePath: String?, title: String, isFavorite: Bool?) {
        self.adult = adult
        self.genres = genres
        self.id = id
        let imagePath = imagePath ?? ""
        self.posterPath = "https://image.tmdb.org/t/p/original\(imagePath)"
        self.title = title
        self.isFavorite = isFavorite ?? false
    }
}
