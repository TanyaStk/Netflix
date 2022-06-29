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
}

final class UserInfoAPI: UserInfo {
    
    let provider = MoyaProvider<TMDB>()
    
    func createRequestToken() -> Single<AuthenticationTokenResponse> {
        return Single.create { [weak self] single in
            self?.provider.rx.request(.token).subscribe { event in
                switch event {
                case .success(let response):
                    let result = try? JSONDecoder().decode(AuthenticationTokenResponse.self, from: response.data)
                    guard let result = result else { return }
                    single(.success(result))
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            return Disposables.create()
        }
    }
}
