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
}

extension TMDB: TargetType {
    
    public var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }
    
    public var path: String {
        switch self {
        case .token: return "/authentication/token/new?api_key=<<api_key>>"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .token:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
