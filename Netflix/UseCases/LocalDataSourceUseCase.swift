//
//  CoreDataUseCase.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 17.08.2022.
//

import Foundation
import UIKit
import CoreData
import RxSwift

protocol LocalDataSourceProtocol {
    func savePopular(models: [Movie]) throws
    func saveLatest(model: LatestMovie) throws
    func fetchLatest() throws -> LatestMovie
}

class LocalDataSourceUseCase: LocalDataSourceProtocol {
    
    enum LocalDataSourceError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        case unknown
    }
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func savePopular(models: [Movie]) throws {
        guard let appDelegate = appDelegate else {
            throw LocalDataSourceError.unknown
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let popularMovies = PopularMovieEntity(context: context)
        
        let movies = models.map { movieModel -> MovieEntity in
            let movieEntity = MovieEntity(context: context)
            movieEntity.id = Int64(movieModel.id)
            movieEntity.isFavorite = movieModel.isFavorite
            movieEntity.posterPath = movieModel.posterPath
            return movieEntity
        }
        let moviesSet = NSSet(array: movies)
        
        popularMovies.addToMovies(moviesSet)
        
        do {
            try context.save()
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }

    func saveLatest(model: LatestMovie) throws {
        guard let appDelegate = appDelegate else {
            throw LocalDataSourceError.unknown
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let latestMovie = LatestMovieEntity(context: context)
        latestMovie.id = Int64(model.id)
        latestMovie.genres = model.genres
        latestMovie.posterPath = model.posterPath
        latestMovie.title = model.title
        
        do {
            try context.save()
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func fetchLatest() throws -> LatestMovie {
        guard let appDelegate = appDelegate else {
            throw LocalDataSourceError.unknown
        }

        let context = appDelegate.persistentContainer.viewContext

        let request: NSFetchRequest<LatestMovieEntity> = LatestMovieEntity.fetchRequest()

        do {
            let movies = try context.fetch(request)
            guard let latestMovie = movies.first else {
                return LatestMovie(adult: false, genres: [], id: 0, imagePath: "", title: "", isFavorite: false)
            }
            return LatestMovie(adult: false,
                               genres: latestMovie.genres ?? [],
                               id: Int(latestMovie.id),
                               imagePath: latestMovie.posterPath,
                               title: latestMovie.title ?? "",
                               isFavorite: false)
        } catch {
            throw LocalDataSourceError.failedToFetchData
        }
    }
}
