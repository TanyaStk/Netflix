//
//  LoginService.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 09.06.2022.
//

import Foundation
import RxSwift

class LoginService {
    
    func login() -> Single<Bool> {
        return Single.just(true)
    }
}
