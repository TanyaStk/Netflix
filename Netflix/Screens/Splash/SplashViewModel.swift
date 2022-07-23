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
    private let loginService: UserInfoAPI
    private let keychainUseCase: KeychainUseCase
    
    init(coordinator: SplashCoordinator,
         loginService: UserInfoAPI,
         keychainUseCase: KeychainUseCase) {
        self.coordinator = coordinator
        self.loginService = loginService
        self.keychainUseCase = keychainUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let success = input.isAppLoaded
            .flatMapLatest { [unowned self] _ -> Driver<Void> in
                guard let user = try self.keychainUseCase.getUser(),
                      self.isTokenExpired(expiring: user.token_expire_at)
                else {
                    errorRelay.accept("Token expired")
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
    
    private func isTokenExpired(expiring date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        guard let expiringDate = dateFormatter.date(from: date) else {
            print("Cannot convert date")
            return false
        }
        let currentDate = Date()        
        return expiringDate > currentDate
    }
    
    private func createSession(for user: User) -> Driver<Void> {
        return loginService
            .createSession(requestToken: user.request_token)
            .do(onSuccess: { result in
                let updatedUser = User(login: user.login,
                                       password: user.password,
                                       request_token: user.request_token,
                                       token_expire_at: user.token_expire_at,
                                       session_id: result.session_id)
                try self.keychainUseCase.update(user: updatedUser)
            }, onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            }).map { _ in }
            .asDriver(onErrorDriveWith: .never())
    }
}
