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
    
    private let loginService = LoginService()
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let validLogin = Observable.combineLatest(input.login, input.password)
            .map { login, password in
                self.isValidLogin(login: login) &&
                self.isValidPassword(password: password)
            }.asDriver(onErrorJustReturn: false)
        
        let successfullyLoggedIn = Observable.merge(input.loginButtonTap, retryLoginRelay.asObservable())
            .withLatestFrom(Observable.combineLatest(input.login, input.password))
            .do(onNext: { [weak self] login, password in
                self?.loadingLogin(with: login, password: password)
            }).map {_ in }
            .asDriver(onErrorDriveWith: Driver.never())
        
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown Error")
        let loginLoading = loginLoadingBehaviorRelay.asDriver()
        
        return Output(isLoginButtonEnabled: validLogin,
                      loginLoading: loginLoading,
                      success: successfullyLoggedIn,
                      error: error)
    }
    
    private func loadingLogin(with login: String, password: String) {
        loginLoadingBehaviorRelay.accept(true)
        loginService.login(login: login, password: password)
            .subscribe(onSuccess: { [weak self] isSuccessfullyLoggedIn in
                self?.loginLoadingBehaviorRelay.accept(false)
                if isSuccessfullyLoggedIn {
                    
                } else {
                    self?.errorRelay.accept("Login failed, check if the correct combination was used and try again")
                }
            }).disposed(by: disposeBag)
    }
    
    private func isValidLogin(login: String) -> Bool {
        return login.count >= 3
    }
    
    private func isValidPassword(password: String) -> Bool {
        return password.count >= 3
    }
}
