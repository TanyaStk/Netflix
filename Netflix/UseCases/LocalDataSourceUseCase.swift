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
    func saveMovie(movie: Movie) throws -> Single<Void>
    func saveToPopular(movie: Movie) throws -> Single<Void>
    func saveToUpcoming(movie: Movie) throws -> Single<Void>
    func saveToFavorites(movie: Movie) throws -> Single<Void>
    func saveMovieDetails(with movieDetails: MovieDetails) throws -> Single<Void>
    func saveAccountDetails(for account: AccountDetails) throws -> Single<Void>
    
    func fetchLatest() throws -> Single<LatestMovie>
    func fetchPopular() throws -> Single<[Movie]>
    func fetchUpcoming() throws -> Single<[Movie]>
    func fetchFavorites() throws -> Single<[Movie]>
    func fetchMovieDetails(for movieId: Int) throws -> Single<MovieDetails>
    func fetchAccountDetails() throws -> Single<AccountDetails>
}

class LocalDataSourceUseCase: LocalDataSourceProtocol {
    
    enum LocalDataSourceError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        case unknown
    }
    
    private let coreDataManager = CoreDataManager()
    private lazy var context = coreDataManager.persistentContainer.viewContext
    
    func saveMovie(movie: Movie) throws -> Single<Void> {
        let movieEntity = MovieEntity(context: context)
        movieEntity.id = Int64(movie.id)
        movieEntity.isFavorite = movie.isFavorite
        movieEntity.posterPath = movie.posterPath
        
        do {
            try context.save()
            return .just(())
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func saveToPopular(movie: Movie) throws -> Single<Void> {
        let popularEntity = PopularEntity(context: context)
        popularEntity.id = Int64(movie.id)
        
        do {
            try context.save()
            return .just(())
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func saveToUpcoming(movie: Movie) throws -> Single<Void> {
        let upcomingEntity = UpcomingEntity(context: context)
        upcomingEntity.id = Int64(movie.id)
        
        do {
            try context.save()
            return .just(())
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func saveToFavorites(movie: Movie) throws -> Single<Void> {
        let favoriteEntity = FavoriteEntity(context: context)
        favoriteEntity.id = Int64(movie.id)
        
        do {
            try context.save()
            return .just(())
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func saveMovieDetails(with movieDetails: MovieDetails) throws -> Single<Void> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", movieDetails.id)
        
        do {
            let movie = try context.fetch(request).first
            movie?.title = movieDetails.title
            movie?.overview = movieDetails.overview
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            movie?.releaseDate = dateFormatter.date(from: movieDetails.releaseDate)
            movie?.voteAverage = Float(movieDetails.voteAverage) ?? 0
            
            try context.save()
            return .just(())
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func saveAccountDetails(for account: AccountDetails) throws -> Single<Void> {
        let userEntity = UserEntity(context: context)
        userEntity.id = Int64(account.id)
        userEntity.name = account.name
        userEntity.username = account.username
        
        do {
            try context.save()
            return .just(())
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func fetchLatest() throws -> Single<LatestMovie> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: false)]
        request.fetchLimit = 1

        do {
            let movies = try context.fetch(request)
            guard let latestMovie = movies.first else {
                return .never()
            }
            return .just(LatestMovie(adult: false,
                                     genres: [],
                                     id: Int(latestMovie.id),
                                     imagePath: latestMovie.posterPath,
                                     title: latestMovie.title ?? "",
                                     isFavorite: false))
        } catch {
            throw LocalDataSourceError.failedToFetchData
        }
    }
    
    func fetchPopular() throws -> Single<[Movie]> {
        let requestPopular: NSFetchRequest<PopularEntity> = PopularEntity.fetchRequest()
        let requestMovies: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        
        do {
            let popularMovies = try context.fetch(requestPopular)
            let movies = try context.fetch(requestMovies)
            let filteredMovies = movies.filter { movieEntity in
                popularMovies.contains { popularEntity in
                    popularEntity.id == movieEntity.id
                }
            }
            
            return .just(filteredMovies.map({ movieEntity in
                Movie(id: Int(movieEntity.id),
                      imagePath: movieEntity.posterPath,
                      isFavorite: movieEntity.isFavorite)
            }))
        } catch {
            throw LocalDataSourceError.failedToFetchData
        }
    }
    
    func fetchUpcoming() throws -> Single<[Movie]> {
        let requestUpcoming: NSFetchRequest<UpcomingEntity> = UpcomingEntity.fetchRequest()
        let requestMovies: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        
        do {
            let upcomingMovies = try context.fetch(requestUpcoming)
            let movies = try context.fetch(requestMovies)
            let filteredMovies = movies.filter { movieEntity in
                upcomingMovies.contains { upcomingEntity in
                    upcomingEntity.id == movieEntity.id
                }
            }
            
            return .just(filteredMovies.map({ movieEntity in
                Movie(id: Int(movieEntity.id),
                      imagePath: movieEntity.posterPath,
                      isFavorite: movieEntity.isFavorite)
            }))
        } catch {
            throw LocalDataSourceError.failedToFetchData
        }
    }
    
    func fetchFavorites() throws -> Single<[Movie]> {
        let requestFavorites: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
        let requestMovies: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        
        do {
            let favoriteMovies = try context.fetch(requestFavorites)
            let movies = try context.fetch(requestMovies)
            let filteredMovies = movies.filter { movieEntity in
                favoriteMovies.contains { favoriteEntity in
                    favoriteEntity.id == movieEntity.id
                }
            }
            
            return .just(filteredMovies.map({ movieEntity in
                Movie(id: Int(movieEntity.id),
                      imagePath: movieEntity.posterPath,
                      isFavorite: movieEntity.isFavorite)
            }))
        } catch {
            throw LocalDataSourceError.failedToFetchData
        }
    }
    
    func fetchMovieDetails(for movieId: Int) throws -> Single<MovieDetails> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", Int64(movieId))
        
        do {
            guard let movie = try context.fetch(request).first else {
                return .never()
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            return .just(MovieDetails(
                id: movieId,
                overview: movie.overview ?? "",
                imagePath: movie.posterPath,
                releaseDate: dateFormatter.string(from: movie.releaseDate ?? Date()),
                runtime: Int(movie.runtime),
                title: movie.title ?? "",
                voteAverage: movie.voteAverage))
        } catch {
            throw LocalDataSourceError.failedToFetchData
        }
    }
    
    func fetchAccountDetails() throws -> Single<AccountDetails> {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.fetchLimit = 1

        do {
            let user = try context.fetch(request).first
            return .just(AccountDetails(
                id: Int(user?.id ?? 0),
                name: user?.name ?? "",
                username: user?.username ?? ""
            ))
        } catch {
            throw LocalDataSourceError.failedToFetchData
        }
    }
}
