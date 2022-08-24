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
        let logoutButtonTap: Observable<Void>
    }
    
    struct Output {
        let accountDetails: Driver<AccountDetails>
        let dismissProfile: Driver<Void>
        let logout: Driver<Void>
        let error: Driver<String>
    }
    
    private let errorRelay = PublishRelay<String>()

    private let coordinator: ProfileCoordinator
    private let service: UserInfoProvider
    private let keychainUseCase: KeychainProtocol
    
    init(coordinator: ProfileCoordinator,
         service: UserInfoProvider,
         keychainUseCase: KeychainProtocol) {
        self.coordinator = coordinator
        self.service = service
        self.keychainUseCase = keychainUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let accountDetails = input.isViewLoaded
            .flatMapLatest { [keychainUseCase, errorRelay, service] _ -> Single<AccountDetailsResponse> in
                guard let user = try keychainUseCase.getUser()
                else {
                    errorRelay.accept("No user exists")
                    return .never()
                }
                return service.getAccountDetails(with: user.session_id)
                
            }
            .do(onError: { [errorRelay] error in
                errorRelay.accept(error.localizedDescription)
            })
            .map { response in
                AccountDetails(id: response.id,
                               name: response.name,
                               username: response.username)
            }
            .asDriver(onErrorJustReturn: AccountDetails(id: 0, name: "", username: ""))
        
        let dismissProfile = input.backButtonTap
            .do { [coordinator] _ in
                coordinator.dismiss()
            }
            .asDriver(onErrorJustReturn: ())
        
        let logout = input.logoutButtonTap
            .do { [keychainUseCase, coordinator] _ in
                try keychainUseCase.deleteUser()
                coordinator.coordinateToOnboarding()
            }
            .asDriver(onErrorJustReturn: ())
        
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown Error")
        
        return Output(accountDetails: accountDetails,
                      dismissProfile: dismissProfile,
                      logout: logout,
                      error: error)
    }
}
