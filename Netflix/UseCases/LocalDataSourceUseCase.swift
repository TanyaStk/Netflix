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
    func saveMovie(movie: MovieResponse) throws
    func saveToPopular(movies: MoviesResultsResponse) throws -> Single<MoviesResultsResponse>
    func saveToUpcoming(movies: MoviesResultsResponse) throws -> Single<MoviesResultsResponse>
    func saveToFavorites(movies: MoviesResultsResponse) throws -> Single<MoviesResultsResponse>
    func saveAccountDetails(for account: AccountDetails) throws -> Single<Void>
    
    func fetchLatest() -> Single<GetLatestResponse>
    func fetchPopular(page: Int) -> Single<MoviesResultsResponse>
    func fetchUpcoming(page: Int) -> Single<MoviesResultsResponse>
    func fetchFavorites() -> Single<MoviesResultsResponse>
    func fetchMovieDetails(for movieId: Int) -> Single<MovieDetailsResponse>
    func fetchAccountDetails() -> Single<AccountDetails>
}

class LocalDataSourceUseCase: LocalDataSourceProtocol {
    enum LocalDataSourceError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        case unknown
    }
    
    private let coreDataManager = CoreDataManager.sharedInstance
    private lazy var context = coreDataManager.persistentContainer.viewContext
    
    func saveMovie(movie: MovieResponse) throws {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "\(movie.id)")
        
        do {
            let existingIndicator = try context.fetch(request)
            if existingIndicator.isEmpty {
                let movieEntity = MovieEntity(context: context)
                initializeMovieEntity(movieEntity: movieEntity, with: movie)
                try context.save()
            } else {
                return
            }
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    private func initializeMovieEntity(movieEntity: MovieEntity, with movie: MovieResponse) {
        movieEntity.id = Int64(movie.id)
        movieEntity.isFavorite = false
        movieEntity.posterPath = movie.poster_path
        movieEntity.voteAverage = movie.vote_average
        movieEntity.overview = movie.overview
        movieEntity.title = movie.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        movieEntity.releaseDate = dateFormatter.date(from: movie.release_date) ?? Date()
    }
    
    func saveToPopular(movies: MoviesResultsResponse) throws -> Single<MoviesResultsResponse> {
        for movie in movies.results {
            let movieEntity = PopularEntity(context: context)
            movieEntity.id = Int64(movie.id)
            
            try saveMovie(movie: movie)
        }
        
        do {
            try context.save()
            return .just(movies)
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func saveToUpcoming(movies: MoviesResultsResponse) throws -> Single<MoviesResultsResponse> {
        for movie in movies.results {
            let movieEntity = UpcomingEntity(context: context)
            movieEntity.id = Int64(movie.id)
            
            try saveMovie(movie: movie)
        }
        
        do {
            try context.save()
            return .just(movies)
        } catch {
            throw LocalDataSourceError.failedToSaveData
        }
    }
    
    func saveToFavorites(movies: MoviesResultsResponse) throws -> Single<MoviesResultsResponse> {
        for movie in movies.results {
            let movieEntity = FavoriteEntity(context: context)
            movieEntity.id = Int64(movie.id)
            
            try saveMovie(movie: movie)
        }
        
        do {
            try context.save()
            return .just(movies)
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
    
    func fetchLatest() -> Single<GetLatestResponse> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: false)]
        request.fetchLimit = 1

        do {
            let movies = try context.fetch(request)
            guard let latestMovie = movies.first else {
                return .never()
            }
            return .just(GetLatestResponse(
                adult: false,
                genres: [],
                id: Int(latestMovie.id),
                poster_path: latestMovie.posterPath,
                title: latestMovie.title ?? "")
            )
        } catch {
            print(LocalDataSourceError.failedToFetchData.localizedDescription)
            return .never()
        }
    }
    
    func fetchPopular(page: Int) -> Single<MoviesResultsResponse> {
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
            let moviesResponse = filteredMovies.map { movieEntity in
                MovieResponse(id: Int(movieEntity.id),
                              poster_path: movieEntity.posterPath,
                              overview: movieEntity.overview ?? "",
                              release_date: DateFormatter().string(from: movieEntity.releaseDate ?? Date()),
                              title: movieEntity.title ?? "",
                              vote_average: movieEntity.voteAverage)
            }
            
            let firstIndex = (page - 1) * 20
            var lastIndex = firstIndex + 19
            
            if lastIndex > moviesResponse.count {
                lastIndex = moviesResponse.count - 1
            }
            
            let response = MoviesResultsResponse(
                page: page,
                results: Array(moviesResponse[firstIndex...lastIndex]),
                total_pages: moviesResponse.count / 20
            )
            return .just(response)
        } catch {
            print(LocalDataSourceError.failedToFetchData.localizedDescription)
            return .never()
        }
    }
    
    func fetchUpcoming(page: Int) -> Single<MoviesResultsResponse> {
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
            let moviesResponse = filteredMovies.map { movieEntity in
                MovieResponse(id: Int(movieEntity.id),
                              poster_path: movieEntity.posterPath,
                              overview: movieEntity.overview ?? "",
                              release_date: DateFormatter().string(from: movieEntity.releaseDate ?? Date()),
                              title: movieEntity.title ?? "",
                              vote_average: movieEntity.voteAverage)
            }
            
            let firstIndex = (page - 1) * 20
            var lastIndex = firstIndex + 19
            
            if lastIndex > moviesResponse.count {
                lastIndex = moviesResponse.count - 1
            }
            
            let response = MoviesResultsResponse(
                page: page,
                results: Array(moviesResponse[firstIndex...lastIndex]),
                total_pages: moviesResponse.count / 20
            )
            return .just(response)
        } catch {
            print(LocalDataSourceError.failedToFetchData.localizedDescription)
            return .never()
        }
    }
    
    func fetchFavorites() -> Single<MoviesResultsResponse> {
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
            let moviesResponse = filteredMovies.map { movieEntity in
                MovieResponse(id: Int(movieEntity.id),
                              poster_path: movieEntity.posterPath,
                              overview: movieEntity.overview ?? "",
                              release_date: DateFormatter().string(from: movieEntity.releaseDate ?? Date()),
                              title: movieEntity.title ?? "",
                              vote_average: movieEntity.voteAverage)
            }
            
            let response = MoviesResultsResponse(page: 0, results: moviesResponse, total_pages: moviesResponse.count)
            return .just(response)
        } catch {
            print(LocalDataSourceError.failedToFetchData.localizedDescription)
            return .never()
        }
    }
    
    func fetchMovieDetails(for movieId: Int) -> Single<MovieDetailsResponse> {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "\(movieId)")
        
        do {
            guard let movie = try context.fetch(request).first else {
                return .never()
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let response = MovieDetailsResponse(
                id: movieId,
                overview: movie.overview ?? "",
                poster_path: movie.posterPath,
                release_date: dateFormatter.string(from: movie.releaseDate ?? Date()),
                runtime: Int(movie.runtime),
                title: movie.title ?? "",
                video: false,
                vote_average: movie.voteAverage)
            return .just(response )
        } catch {
            print(LocalDataSourceError.failedToFetchData.localizedDescription)
            return .never()
        }
    }
    
    func fetchAccountDetails() -> Single<AccountDetails> {
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
            print(LocalDataSourceError.failedToFetchData.localizedDescription)
            return .never()
        }
    }
}
