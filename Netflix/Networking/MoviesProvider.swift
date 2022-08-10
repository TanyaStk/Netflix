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
    func getPopular(page: Int) -> Single<MoviesResultsResponse>
    func getUpcoming() -> Single<MoviesResultsResponse>
    func getDetails(for movieId: Int) -> Single<MovieDetailsResponse>
    func search(for movie: String) -> Single<MoviesResultsResponse>
    func getVideos(for movieId: Int) -> Single<GetVideosResponse>
}

final class MoviesProvider: Movies {

    private let provider = MoyaProvider<MoviesAPI>()

    func getLatest() -> Single<GetLatestResponse> {
        return provider.rx.request(.latest)
            .catchResponseError(NetworkingErrorResponse.self)
            .map(GetLatestResponse.self)
    }
    
    func getPopular(page: Int) -> Single<MoviesResultsResponse> {
        return provider.rx.request(.popular(page: page))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesResultsResponse.self)
    }
    
    func getUpcoming() -> Single<MoviesResultsResponse> {
        return provider.rx.request(.upcoming)
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesResultsResponse.self)
    }
    
    func getDetails(for movieId: Int) -> Single<MovieDetailsResponse> {
        return provider.rx.request(.details(movieId: movieId))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MovieDetailsResponse.self)
    }
    
    func search(for movie: String) -> Single<MoviesResultsResponse> {
        return provider.rx.request(.search(query: movie))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesResultsResponse.self)
    }
    
    func getVideos(for movieId: Int) -> Single<GetVideosResponse> {
        return provider.rx.request(.videos(movieId: movieId))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(GetVideosResponse.self)
    }
}
