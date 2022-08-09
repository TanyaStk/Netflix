//
//  MoviesProvider.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation
import RxSwift
import Moya

protocol Movies {
    func getLatest() -> Single<GetLatestResponse>
    func getPopular() -> Single<MoviesResultsResponse>
    func getUpcoming(page: Int) -> Single<MoviesResultsResponse>
    func getDetails(movieId: String) -> Single<MovieDetailsResponse>
    func search(for movie: String) -> Single<MoviesResultsResponse>
}

final class MoviesProvider: Movies {
    
    private let provider = MoyaProvider<MoviesAPI>()

    func getLatest() -> Single<GetLatestResponse> {
        return provider.rx.request(.latest)
            .catchResponseError(NetworkingErrorResponse.self)
            .map(GetLatestResponse.self)
    }
    
    func getPopular() -> Single<MoviesResultsResponse> {
        return provider.rx.request(.popular)
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesResultsResponse.self)
    }
    
    func getUpcoming(page: Int) -> Single<MoviesResultsResponse> {
        return provider.rx.request(.upcoming(page: page))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesResultsResponse.self)
    }
    
    func getDetails(movieId: String) -> Single<MovieDetailsResponse> {
        return provider.rx.request(.details(movieId: movieId))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MovieDetailsResponse.self)
    }
    
    func search(for movie: String) -> Single<MoviesResultsResponse> {
        return provider.rx.request(.search(query: movie))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesResultsResponse.self)
    }
}
