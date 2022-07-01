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

final class UserInfoAPI: UserInfo {

    let provider = MoyaProvider<TMDB>()
    
    func createRequestToken() -> Single<AuthenticationTokenResponse> {
        return provider.rx.request(.token)
            .filterSuccessfulStatusCodes()
            .map(AuthenticationTokenResponse.self)
    }
    
    func createSession(requestToken: String) -> Single<CreateSessionResponse> {
        return provider.rx.request(.session(requestToken: requestToken))
            .filterSuccessfulStatusCodes()
            .map(CreateSessionResponse.self)
    }
    
    func createSessionWithLogin(username: String, password: String, requestToken: String) -> Single<AuthenticationTokenResponse> {
        return provider.rx.request(.sessionWith(login: username, password: password, requestToken: requestToken))
            .filterSuccessfulStatusCodes()
            .map(AuthenticationTokenResponse.self)
    }

}
