//
//  UserInfo.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.06.2022.
//

import Foundation
import RxSwift
import Moya

protocol UserInfo {
    
    func createRequestToken() -> Single<AuthenticationTokenResponse>
    func createSession(requestToken: String) -> Single<CreateSessionResponse>
    func createSessionWithLogin(username: String,
                                password: String,
                                requestToken: String) -> Single<AuthenticationTokenResponse>
}

final class UserInfoProvider: UserInfo {
    
    let provider = MoyaProvider<UserInfoAPI>()
    
    func createRequestToken() -> Single<AuthenticationTokenResponse> {
        return provider.rx.request(.token)
            .catchResponseError(NetworkingErrorResponse.self)
            .map(AuthenticationTokenResponse.self)
    }
    
    func createSession(requestToken: String) -> Single<CreateSessionResponse> {
        return provider.rx.request(.session(requestToken: requestToken))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(CreateSessionResponse.self)
    }
    
    func createSessionWithLogin(username: String, password: String, requestToken: String) -> Single<AuthenticationTokenResponse> {
        return provider.rx.request(.sessionWith(login: username, password: password, requestToken: requestToken))
            .catchResponseError(NetworkingErrorResponse.self)
            .map(AuthenticationTokenResponse.self)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func catchResponseError(_ type: NetworkingErrorResponse.Type) -> Single<Element> {
        return flatMap { response in
            guard (200...299).contains(response.statusCode) else {
                do {
                    let errorResponse = try response.map(type.self)
                    throw NetworkingError(message: errorResponse.status_message)
                } catch {
                    throw error
                }
            }
            return .just(response)
        }
    }
}