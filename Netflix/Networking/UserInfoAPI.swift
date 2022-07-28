//
//  TMDB.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 29.06.2022.
//

import Foundation
import RxSwift
import Moya

public enum UserInfoAPI {
    
    static private let apiKey = "7ce563134c101dab6bb4df8a68a6d3bf"
    
    case token
    case session(requestToken: String)
    case sessionWith(login: String, password: String, requestToken: String)
}

extension UserInfoAPI: TargetType {
    
    public var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }
    
    public var path: String {
        switch self {
        case .token:
            return "/authentication/token/new"
        case .session:
            return "/authentication/session/new"
        case .sessionWith:
            return "/authentication/token/validate_with_login"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .token:
            return .get
        case .sessionWith, .session:
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
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
