//
//  ProfileCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class ProfileCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let profileViewModel = ProfileViewModel(
            coordinator: self,
            service: UserInfoProvider(),
            keychainUseCase: KeychainUseCase())
        
        let profileViewController = ProfileViewController()
        profileViewController.viewModel = profileViewModel        
        profileViewController.modalPresentationStyle = .fullScreen

        navigationController.present(profileViewController, animated: true)
    }
    
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
    
    func coordinateToOnboarding() {
        navigationController.dismiss(animated: true)
        
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.start()
    }
}
