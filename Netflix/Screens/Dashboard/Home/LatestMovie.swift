//
//  LatestMovie.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 03.08.2022.
//

import Foundation

struct LatestMovie: Codable {
    var id: Int
    var posterPath: String
    var title: String
    var isFavorite: Bool?
    
    init(id: Int, imagePath: String?, title: String, isFavorite: Bool?) {
        self.id = id
        let imagePath = imagePath ?? ""
        self.posterPath = "https://image.tmdb.org/t/p/original\(imagePath)"
        self.title = title
        self.isFavorite = isFavorite ?? false
    }
}
