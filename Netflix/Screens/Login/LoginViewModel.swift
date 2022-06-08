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
    }
    
    let input: Input
    let output: Output
    
    private let loginSubject = PublishSubject<String>()
    private let passwordSubject = PublishSubject<String>()
    private let loginButtonTapSubject = PublishSubject<Void>()
    private let isLoginButtonEnabledSubject = PublishSubject<Bool>()
    
    init() {
        input = Input(login: loginSubject.asObservable(),
                      password: passwordSubject.asObservable(),
                      loginButtonTap: loginButtonTapSubject.asObservable())
        
        output = Output(isLoginButtonEnabled: isLoginButtonEnabledSubject.asDriver(onErrorJustReturn: false))
    }
    
    func transform(_ input: Input) -> Output {
        let validLogin = Observable.combineLatest(input.login, input.password)
            .map { login, password in
                self.isValidLogin(login: login) &&
                self.isValidPassword(password: password)
            }.asDriver(onErrorJustReturn: false)
        
        return Output(isLoginButtonEnabled: validLogin)
    }
    
    private func isValidLogin(login: String) -> Bool {
        return login.count >= 3
    }
    
    private func isValidPassword(password: String) -> Bool {
        return password.count >= 3
    }
}
