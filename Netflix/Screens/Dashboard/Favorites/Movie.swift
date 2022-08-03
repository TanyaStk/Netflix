//
//  Movie.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 01.08.2022.
//

import Foundation

struct Movie: Codable {
    var id: Int
    var posterPath: String
    var isFavorite: Bool?
    
    init(id: Int, imagePath: String?, isFavorite: Bool?) {
        self.id = id
        let imagePath = imagePath ?? ""
        self.posterPath = "https://image.tmdb.org/t/p/original\(imagePath)"
        self.isFavorite = isFavorite ?? false
    }
}
