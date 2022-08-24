//
//  MoviesProviderAPIWithCache.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 19.08.2022.
//

import Foundation
import RxSwift

final class MoviesProviderAPIWithCache: MoviesProviderProtocol {
    
    private let apiProvider = MoviesProviderAPI()
    private let localDataSourceUseCase = LocalDataSourceUseCase()
    
    func getLatest() -> Single<GetLatestResponse> {
        return apiProvider.getLatest()
    }
    
    func getUpcoming(page: Int) -> Single<MoviesResultsResponse> {
        return apiProvider.getUpcoming(page: page)
            .flatMap { moviesResultsResponse in
               try self.localDataSourceUseCase.saveToUpcoming(movies: moviesResultsResponse)
            }
    }
    
    func getPopular(page: Int) -> Single<MoviesResultsResponse> {
        return apiProvider.getPopular(page: page)
            .flatMap { moviesResultsResponse in
               try self.localDataSourceUseCase.saveToPopular(movies: moviesResultsResponse)
            }
    }
    
    func getDetails(movieId: Int) -> Single<MovieDetailsResponse> {
        return apiProvider.getDetails(movieId: movieId)
    }
    
    func search(for movie: String, on page: Int) -> Single<MoviesResultsResponse> {
        return apiProvider.search(for: movie, on: page)
    }
    
    func getVideos(for movieId: Int) -> Single<GetVideosResponse> {
        return apiProvider.getVideos(for: movieId)
    }
}
