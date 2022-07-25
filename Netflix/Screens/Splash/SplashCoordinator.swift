//
//  SplashCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 24.05.2022.
//

import Foundation
import UIKit

class SplashCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let splashViewController = SplashViewController()
        let splashViewModel = SplashViewModel(coordinator: self,
                                              loginService: UserInfoProvider(),
                                              keychainUseCase: KeychainUseCase())
        splashViewController.viewModel = splashViewModel
        
        navigationController.pushViewController(splashViewController, animated: false)
    }
    
    func coordinateToDashboard() {
        let dashboardCoordinator = DashboardCoordinator(navigationController: navigationController)
        dashboardCoordinator.start()
    }
    
    func coordinateToOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.start()
    }
}
