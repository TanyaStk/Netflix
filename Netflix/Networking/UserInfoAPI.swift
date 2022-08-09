//
//  TMDB.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 29.06.2022.
//

import Foundation
import Moya

public enum UserInfoAPI {
    
    static private let apiKey = "7ce563134c101dab6bb4df8a68a6d3bf"
    
    case token
    case session(requestToken: String)
    case sessionWith(login: String, password: String, requestToken: String)
    case favoriteMovies(accountId: String)
    case accountDetails(sessionId: String)
    case markAsFavorite(accountId: String, mediaType: String, mediaId: Int, favorite: Bool)
    case isFavorite(sessionId: String, movieId: Int)
}

extension UserInfoAPI: TargetType {
    
    public var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3/")!
    }
    
    public var path: String {
        switch self {
        case .token:
            return "authentication/token/new"
        case .session:
            return "authentication/session/new"
        case .sessionWith:
            return "authentication/token/validate_with_login"
        case .favoriteMovies(let accountId):
            return "account/\(accountId)/favorite/movies"
        case .accountDetails:
            return "account"
        case .markAsFavorite(let accountId, _, _, _):
            return "account/\(accountId)/favorite"
        case .isFavorite(_, let movieId):
            return "movie/\(movieId)/account_states"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .token, .favoriteMovies, .accountDetails, .isFavorite:
            return .get
        case .sessionWith, .session, .markAsFavorite:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .token:
            return .requestParameters(
                parameters: ["api_key": "\(UserInfoAPI.apiKey)"],
                encoding: URLEncoding.queryString)
        case .session(let requestToken):
            return .requestParameters(
                parameters: ["api_key": "\(UserInfoAPI.apiKey)",
                             "request_token": "\(requestToken)"],
                encoding: URLEncoding.queryString)
        case let .sessionWith(username, password, requestToken):
            let parameters = [
                "api_key": "\(UserInfoAPI.apiKey)",
                "username": username,
                "password": password,
                "request_token": requestToken
            ]
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.queryString)
        case .accountDetails(let sessionId), .favoriteMovies(let sessionId), .isFavorite(let sessionId, _):
            return .requestParameters(
                parameters: ["api_key": "\(UserInfoAPI.apiKey)",
                             "session_id": "\(sessionId)"],
                encoding: URLEncoding.queryString)
        case .markAsFavorite(let sessionId, let mediaType, let mediaId, let favorite):
            let parameters = [
                "api_key": "\(UserInfoAPI.apiKey)",
                "session_id": sessionId,
                "media_type": mediaType,
                "media_id": "\(mediaId)",
                "favorite": "\(favorite)"
            ]
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
