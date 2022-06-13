//
//  LoginService.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 09.06.2022.
//

import Foundation
import RxSwift

class LoginService {
    
    func login(login: String, password: String) -> Single<Bool> {
        let isCorrectCombination = login == "email" && password == "password"
        return Single.just(isCorrectCombination)
    }
}
