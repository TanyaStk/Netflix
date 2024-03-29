//
//  MoviesAPI.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation
import Moya

public enum MoviesAPI {

    static private let apiKey = "7ce563134c101dab6bb4df8a68a6d3bf"
    
    case latest
    case upcoming(page: Int)
    case popular(page: Int)
    case details(movieId: Int)
    case search(query: String, page: Int)
    case videos(movieId: Int)
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
        case .videos(let movieId):
            return "/movie/\(movieId)/videos"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Task {
        switch self {
        case .latest, .details, .videos:
            return .requestParameters(
                parameters: ["api_key": "\(MoviesAPI.apiKey)"],
                encoding: URLEncoding.queryString)
        case .search(let query, let page):
            return .requestParameters(
                parameters: ["api_key": MoviesAPI.apiKey,
                             "query": query,
                             "page": "\(page)"],
                encoding: URLEncoding.queryString)
        case .upcoming(let page), .popular(let page):
            return .requestParameters(
                parameters: ["api_key": MoviesAPI.apiKey,
                             "page": "\(page)"],
                encoding: URLEncoding.queryString)
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
