//
//  MoviesProviderDataBase.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 19.08.2022.

import Foundation
import RxSwift

final class MoviesProviderDataBase: MoviesProviderProtocol {
    
    private let localDataSourceUseCase = LocalDataSourceUseCase()
    
    func getLatest() -> Single<GetLatestResponse> {
        return localDataSourceUseCase.fetchLatest()
    }
    
    func getUpcoming(page: Int) -> Single<MoviesResultsResponse> {
        return localDataSourceUseCase.fetchUpcoming(page: page)
    }
    
    func getPopular(page: Int) -> Single<MoviesResultsResponse> {
        return localDataSourceUseCase.fetchPopular(page: page)
    }
    
    func getDetails(movieId: Int) -> Single<MovieDetailsResponse> {
        return localDataSourceUseCase.fetchMovieDetails(for: movieId)
    }
    
    func search(for movie: String, on page: Int) -> Single<MoviesResultsResponse> {
        return .never()
    }
    
    func getVideos(for movieId: Int) -> Single<GetVideosResponse> {
        return .never()
    }
}
