//
//  ProfileViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 29.07.2022.
//

import Foundation
import RxCocoa
import RxSwift

class ProfileViewModel: ViewModel {
    struct Input {
        let isViewLoaded: Observable<Bool>
        let backButtonTap: Observable<Void>
    }
    
    struct Output {
        let userDetails: Driver<AccountDetailsResponse>
        let dismissProfile: Driver<Void>
        let error: Driver<String>
    }
    
    private let errorRelay = PublishRelay<String>()

    private let coordinator: ProfileCoordinator
    private let service: UserInfoProvider
    private let keychainUseCase: KeychainUseCase
    
    init(coordinator: ProfileCoordinator,
         service: UserInfoProvider,
         keychainUseCase: KeychainUseCase) {
        self.coordinator = coordinator
        self.service = service
        self.keychainUseCase = keychainUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let userDetails = input.isViewLoaded
            .flatMapLatest { [unowned self] _ -> Single<AccountDetailsResponse> in
                guard let user = try self.keychainUseCase.getUser()
                else {
                    errorRelay.accept("No user exists")
                    return .never()
                }
                return service.getAccountDetails(with: user.session_id)
            }
            .do(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .asDriver(onErrorJustReturn: AccountDetailsResponse(id: 0, name: "", username: ""))
        
        let dismissProfile = input.backButtonTap
            .do { [weak self] _ in
                self?.coordinator.dismiss()
            }
            .asDriver(onErrorJustReturn: ())
        
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown Error")
        
        return Output(userDetails: userDetails,
                      dismissProfile: dismissProfile,
                      error: error)
    }
}
