//
//  LoginViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 30.05.2022.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    
    struct Input {
        let login: Observable<String>
        let password: Observable<String>
        let loginButtonTap: Observable<Void>
    }
    
    struct Output {
        let isLoginButtonEnabled: Driver<Bool>
        let loginLoading: Driver<Bool>
        let success: Driver<Void>
        let error: Driver<String>
    }
    
    private let loginLoadingBehaviorRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let retryLoginRelay = PublishRelay<Void>()
    
    private let loginService: UserInfoAPI
    private let disposeBag = DisposeBag()
    
    init(loginService: UserInfoAPI) {
        self.loginService = loginService
    }
    
    func transform(_ input: Input) -> Output {
        let isCredentialsValid = Observable.combineLatest(input.login, input.password)
            .map { [weak self] login, password in
                self?.isValidLogin(login: login) ?? false &&
                self?.isValidPassword(password: password) ?? false
            }.asDriver(onErrorJustReturn: false)
        
        let successfullyLoggedIn = Observable
            .merge(input.loginButtonTap, retryLoginRelay.asObservable())
            .withLatestFrom(Observable.combineLatest(input.login, input.password) {
                (login: $0, password: $1)
            })
            .do(onNext: { [weak self] credentials in
                self?.loginLoadingBehaviorRelay.accept(true)
            })
            .flatMapLatest { [unowned self] credentials in
                self.loadingLogin(with: credentials.login, password: credentials.password)
            }
            .do(onNext: { [weak self] _ in
                self?.loginLoadingBehaviorRelay.accept(false)
            }).map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown Error")
        let loginLoading = loginLoadingBehaviorRelay.asDriver()
        
        return Output(isLoginButtonEnabled: isCredentialsValid,
                      loginLoading: loginLoading,
                      success: successfullyLoggedIn,
                      error: error)
    }
    
    private func loadingLogin(with login: String, password: String) -> Driver<Void> {
        var token = ""
        return loginService.createRequestToken()
            .flatMap { [weak self] response -> Single<AuthenticationTokenResponse> in
                return self?.loginService.createSessionWithLogin(
                    username: login,
                    password: password,
                    requestToken: response.request_token) ?? .never()
            }
            .flatMap { [weak self] sessionResponse -> Single<CreateSessionResponse> in
                token = sessionResponse.request_token
                return self?.loginService.createSession(requestToken: sessionResponse.request_token) ?? .never()
            }
            .do(onSuccess: { result in
                let user = User(login: login,
                                password: password,
                                request_token: token,
                                session_id: result.session_id)
                try KeychainUseCase.deleteUser()
                try KeychainUseCase.save(user: user)
            }, onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            }).map { _ in }
            .asDriver(onErrorDriveWith: .never())
    }
    
    private func isValidLogin(login: String) -> Bool {
        return login.count >= 3
    }
    
    private func isValidPassword(password: String) -> Bool {
        return password.count >= 3
    }
}
