//
//  MoviesAPI.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation
import Moya

public enum MoviesAPI {

    static private let apiKey = ""
    
    case latest
    case popular
    case upcoming
    case details(movieId: String)
    case search(query: String)
}

extension MoviesAPI: TargetType {

    public var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3/")!
    }

    public var path: String {
        switch self {
        case .latest:
            return "movie/latest"
        case .popular:
            return "movie/popular"
        case .upcoming:
            return "movie/upcoming"
        case .details(let movieId):
            return "movie/\(movieId)"
        case .search:
            return "search/movie"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Task {
        switch self {
        case .latest, .popular, .upcoming, .details:
            return .requestParameters(
                parameters: ["api_key": "\(MoviesAPI.apiKey)"],
                encoding: URLEncoding.queryString)
        case .search(let query):
            return .requestParameters(
                parameters: ["query": query,
                             "api_key": MoviesAPI.apiKey],
                encoding: URLEncoding.queryString)
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}