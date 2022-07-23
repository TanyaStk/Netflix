//
//  OnboardingCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import Foundation
import UIKit
 
class OnboardingCoordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let onboardingViewController = OnboardingViewController()
        let onboardingViewModel = OnboardingViewModel(coordinator: self)
        onboardingViewController.viewModel = onboardingViewModel
        onboardingViewController.modalPresentationStyle = .fullScreen
        
        navigationController.present(onboardingViewController, animated: false)
    }
    
    func coordinateToLogin() {
        navigationController.dismiss(animated: false)
        
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.start()
    }
}
