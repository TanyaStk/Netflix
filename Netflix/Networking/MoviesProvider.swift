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
    func getPopular() -> Single<MoviesListResponse>
    func getUpcoming() -> Single<MoviesListResponse>
    func getDetails(movieId: String) -> Single<MovieDetailsResponse>
    func search(for movie: String) -> Single<SearchResultResponse>
}

final class MoviesProvider: Movies {
    
    private let provider = MoyaProvider<MoviesAPI>()
    
    func getLatest() -> Single<GetLatestResponse> {
        return provider.rx.request(.latest)
            .catchResponseError(NetworkingErrorResponse.self)
            .map(GetLatestResponse.self)
    }
    
    func getPopular() -> Single<MoviesListResponse> {
        return provider.rx.request(.popular)
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesListResponse.self)
    }
    
    func getUpcoming() -> Single<MoviesListResponse> {
        return provider.rx.request(.upcoming)
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesListResponse.self)
    }
    
    func getDetails(movieId: String) -> Single<MovieDetailsResponse> {
        return provider.rx.request(.details(movieId: movieId))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MovieDetailsResponse.self)
    }
    
    func search(for movie: String) -> Single<SearchResultResponse> {
        return provider.rx.request(.search(query: movie))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(SearchResultResponse.self)
    }
}
