//
//  OnboardingViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 20.07.2022.
//

import Foundation
import RxSwift
import RxCocoa

class OnboardingViewModel: ViewModel {
    
    struct Input {
        let signInButtonTap: Observable<Void>
        let signUpButtonTap: Observable<Void>
    }
    
    struct Output {
        let signInButtonTap: Driver<Void>
        let signUpButtonTap: Driver<Void>
    }
    
    private let coordinator: OnboardingCoordinator
    
    init(coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(_ input: Input) -> Output {
        let signIpButtonTap = input.signInButtonTap
            .do(onNext: { [weak self] _ in
                self?.coordinator.coordinateToLogin()
            })
            .asDriver(onErrorDriveWith: .never())
        
        let signUpButtonTap = input.signUpButtonTap
            .do(onNext: { _ in
                if let url = URL(string: "https://www.themoviedb.org/signup") {
                    UIApplication.shared.open(url)
                }
            })
            .asDriver(onErrorDriveWith: .never())
        
        return Output(signInButtonTap: signIpButtonTap,
                      signUpButtonTap: signUpButtonTap)
    }
}
