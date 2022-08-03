//
//  DetailedMovie.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 02.08.2022.
//

import Foundation

struct MovieDetails {
    let id: Int
    let overview: String
    let posterPath: String
    let releaseDate: String
    let runtime: Int
    let title: String
    let voteAverage: String
    
    init(id: Int,
         overview: String,
         imagePath: String?,
         releaseDate: String,
         runtime: Int, title: String,
         voteAverage: Float) {
        self.id = id
        self.overview = overview
        let imagePath = imagePath ?? ""
        self.posterPath = "https://image.tmdb.org/t/p/original\(imagePath)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        let date = dateFormatter.date(from: releaseDate) ?? Date()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        self.releaseDate = dateFormatter.string(from: date)
        self.runtime = runtime
        self.title = title
        self.voteAverage = String(format: "%.1f", voteAverage)
    }
}
