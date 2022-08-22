//
//  MoviesProvider.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 22.08.2022.
//

import Foundation
import RxSwift
import Network

protocol MoviesProviderProtocol {
    func getLatest() -> Single<GetLatestResponse>
    func getUpcoming(page: Int) -> Single<MoviesResultsResponse>
    func getPopular(page: Int) -> Single<MoviesResultsResponse>
    func getDetails(movieId: Int) -> Single<MovieDetailsResponse>
    func search(for movie: String, on page: Int) -> Single<MoviesResultsResponse>
    func getVideos(for movieId: Int) -> Single<GetVideosResponse>
}

final class MoviesProvider: MoviesProviderProtocol {
    
    private let onlineProvider = MoviesProviderAPIWithCache()
    private let offlineProvider = MoviesProviderDataBase()
    
    private var current: MoviesProviderProtocol {
        return NetworkMonitor.shared.isConnected ? onlineProvider : offlineProvider
    }

    func getLatest() -> Single<GetLatestResponse> {
        return current.getLatest()
    }
    
    func getUpcoming(page: Int) -> Single<MoviesResultsResponse> {
        return current.getUpcoming(page: page)
    }
    
    func getPopular(page: Int) -> Single<MoviesResultsResponse> {
        return current.getPopular(page: page)
    }
    
    func getDetails(movieId: Int) -> Single<MovieDetailsResponse> {
        return current.getDetails(movieId: movieId)
    }
    
    func search(for movie: String, on page: Int) -> Single<MoviesResultsResponse> {
        return current.search(for: movie, on: page)
    }
    
    func getVideos(for movieId: Int) -> Single<GetVideosResponse> {
        return current.getVideos(for: movieId)
    }
}
