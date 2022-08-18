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
    func saveMoviesFor(categoryName: String, models: [Movie]) throws
    func fetchMoviesFor(categoryName: String) throws -> [Movie]
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
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    private lazy var context = appDelegate!.persistentContainer.viewContext
    
    func saveMoviesFor(categoryName: String, models: [Movie]) throws {
        let category = CategoryEntity(context: context)
        category.name = categoryName
        
        let movies = models.map { movieModel -> MovieEntity in
            let movieEntity = MovieEntity(context: context)
            movieEntity.id = Int64(movieModel.id)
            movieEntity.isFavorite = movieModel.isFavorite
            movieEntity.posterPath = movieModel.posterPath
            return movieEntity
        }
        let moviesSet = NSSet(array: movies)
        
        category.addToMovies(moviesSet)
        
        do {
            try context.save()
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func fetchMoviesFor(categoryName: String) throws -> [Movie] {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category = %@", categoryName)
        
        do {
            let movies = try context.fetch(request)
            return movies.map { movieEntity in
                Movie(id: Int(movieEntity.id),
                      imagePath: movieEntity.posterPath,
                      isFavorite: movieEntity.isFavorite
                )
            }
        } catch {
            throw LocalDataSourceError.failedToFetchData
        }
    }

    func saveLatest(model: LatestMovie) throws {
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
