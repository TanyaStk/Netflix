//
//  SplashViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 24.05.2022.
//

import Foundation
import RxSwift
import RxCocoa

class SplashViewModel: ViewModel {
    
    struct Input {
        let isAppLoaded: Observable<Bool>
    }
    
    struct Output {
        let success: Driver<Void>
        let error: Driver<String>
    }
    
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: SplashCoordinator
    private let loginService: UserInfoProvider
    private let keychainUseCase: Keychain
    
    init(coordinator: SplashCoordinator,
         loginService: UserInfoProvider,
         keychainUseCase: Keychain) {
        self.coordinator = coordinator
        self.loginService = loginService
        self.keychainUseCase = keychainUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let success = input.isAppLoaded
            .flatMapLatest { [unowned self] _ -> Driver<Void> in
                guard let user = try self.keychainUseCase.getUser()
                else {
                    return .never()
                }
                return self.createSession(for: user)
            }
            .do(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asObservable()
        
        let delayedSuccess = Observable.zip(
            success,
            Observable<Int>.timer(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance),
            resultSelector: { success, _ in
                return success
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
            .do(onNext: { [weak self] _ in
                self?.coordinator.coordinateToDashboard()
            })
        
        let delayedError = Observable.zip(
            errorRelay.asObservable(),
            Observable<Int>.timer(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance),
            resultSelector: { error, _ in
                return error
            })
            .asDriver(onErrorJustReturn: "Unknown Error")
            .do(onNext: { [weak self] _ in
                self?.coordinator.coordinateToOnboarding()
            })
        
        return Output(success: delayedSuccess,
                      error: delayedError)
    }

    private func createSession(for user: User) -> Driver<Void> {
        var token = ""
        return loginService.createRequestToken()
            .flatMap { [weak self] response -> Single<AuthenticationTokenResponse> in
                return self?.loginService.createSessionWithLogin(
                    username: user.login,
                    password: user.password,
                    requestToken: response.request_token) ?? .never()
            }
            .flatMap { [weak self] sessionResponse -> Single<CreateSessionResponse> in
                token = sessionResponse.request_token
                return self?.loginService.createSession(requestToken: sessionResponse.request_token) ?? .never()
            }
            .do(onSuccess: { result in
                let updatedUser = User(login: user.login,
                                       password: user.password,
                                       request_token: token,
                                       session_id: result.session_id)
                try self.keychainUseCase.update(user: updatedUser)
            }, onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            }).map { _ in }
            .asDriver(onErrorDriveWith: .never())
    }
}
