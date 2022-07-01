//
//  TMDB.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 29.06.2022.
//

import Foundation
import RxSwift
import Moya

public enum TMDB {
    
    static private let publicKey = ""
    static private let privateKey = ""
    
    case token
    case session(requestToken: String)
    case sessionWith(login: String, password: String, requestToken: String)
}

extension TMDB: TargetType {
    
    public var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }
    
    public var path: String {
        switch self {
        case .token:
            return "/authentication/token/new?api_key=\(TMDB.publicKey)"
        case .session(let requestToken):
            return "/authentication/session/new?api_key=\(TMDB.publicKey)&request_token=\(requestToken)"
        case .sessionWith:
            return "/authentication/session/new?api_key=\(TMDB.publicKey)"
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
        case let .sessionWith(username, password, requestToken):
            let parameters = [
                "username": username,
                "password": password,
                "request_token": requestToken
            ]
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
