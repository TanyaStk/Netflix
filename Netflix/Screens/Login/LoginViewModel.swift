//
//  LoginViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 30.05.2022.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: ViewModel {
    
    struct Input {
        let login: Observable<String>
        let password: Observable<String>
        let loginButtonTap: Observable<Void>
        let showPasswordButtonTap: Observable<Void>
    }
    
    struct Output {
        let isLoginButtonEnabled: Driver<Bool>
        let changePasswordVisibility: Driver<Void>
        let isPasswordHidden: Driver<Bool>
        let loginLoading: Driver<Bool>
        let success: Driver<Void>
        let error: Driver<String>
    }
    
    private let loginLoadingBehaviorRelay = BehaviorRelay<Bool>(value: false)
    private let isPasswordHiddenBehaviorRelay = BehaviorRelay<Bool>(value: true)
    private let errorRelay = PublishRelay<String>()
    private let retryLoginRelay = PublishRelay<Void>()
    
    private let coordinator: LoginCoordinator
    private let loginService: UserInfoProvider
    private let keychainUseCase: KeychainUseCase
    
    init(coordinator: LoginCoordinator,
         loginService: UserInfoProvider,
         keychainUseCase: KeychainUseCase) {
        self.coordinator = coordinator
        self.loginService = loginService
        self.keychainUseCase = keychainUseCase
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
            .do(onNext: { [weak self] _ in
                self?.loginLoadingBehaviorRelay.accept(true)
            })
            .flatMapLatest { [unowned self] credentials in
                self.loadingLogin(with: credentials.login, password: credentials.password)
            }
            .do(onNext: { [weak self] _ in
                self?.loginLoadingBehaviorRelay.accept(false)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
            .do(onNext: { [weak self] _ in
                self?.coordinator.coordinateToDashboard()
            })
        
        let showPassword = input.showPasswordButtonTap
            .do { [isPasswordHiddenBehaviorRelay] _ in
                    isPasswordHiddenBehaviorRelay.accept(!isPasswordHiddenBehaviorRelay.value)
            }
            .asDriver(onErrorJustReturn: ())
        
        let isPasswordHidden = isPasswordHiddenBehaviorRelay.asDriver()
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown Error")
        let loginLoading = loginLoadingBehaviorRelay.asDriver()
        
        return Output(isLoginButtonEnabled: isCredentialsValid,
                      changePasswordVisibility: showPassword,
                      isPasswordHidden: isPasswordHidden,
                      loginLoading: loginLoading,
                      success: successfullyLoggedIn,
                      error: error)
    }
    
    private func loadingLogin(with login: String, password: String) -> Driver<Void> {
        var token = ""
        var tokenExpireAt = ""
        return loginService.createRequestToken()
            .flatMap { [weak self] response -> Single<AuthenticationTokenResponse> in
                return self?.loginService.createSessionWithLogin(
                    username: login,
                    password: password,
                    requestToken: response.request_token) ?? .never()
            }
            .flatMap { [weak self] sessionResponse -> Single<CreateSessionResponse> in
                token = sessionResponse.request_token
                tokenExpireAt = sessionResponse.expires_at
                return self?.loginService.createSession(requestToken: sessionResponse.request_token) ?? .never()
            }
            .do(onSuccess: { result in
                let user = User(login: login,
                                password: password,
                                request_token: token,
                                token_expire_at: tokenExpireAt,
                                session_id: result.session_id)
                try self.keychainUseCase.save(user: user)
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
