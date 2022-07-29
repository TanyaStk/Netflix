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
    func getUpcoming() -> Single<MoviesListResponse>
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
    
    func search(for movie: String) -> Single<MoviesResultsResponse> {
        return provider.rx.request(.search(query: movie))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(MoviesResultsResponse.self)
    }
}

//struct VerbosePlugin: PluginType {
//    let verbose: Bool
//
//    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
//        #if DEBUG
//        if let body = request.httpBody,
//           let str = String(data: body, encoding: .utf8) {
//            if verbose {
//                print("request to send: \(str))")
//            }
//        }
//        #endif
//        return request
//    }
//
//    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
//        #if DEBUG
//        switch result {
//        case .success(let body):
//            if verbose {
//                print("Response:")
//                if let json = try? JSONSerialization.jsonObject(with: body.data, options: .mutableContainers) {
//                    print(json)
//                } else {
//                    let response = String(data: body.data, encoding: .utf8)!
//                    print(response)
//                }
//            }
//        case .failure( _):
//            break
//        }
//        #endif
//    }
//}
