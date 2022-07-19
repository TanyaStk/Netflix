//
//  LoginCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 30.05.2022.
//

import Foundation
import UIKit

class LoginCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let loginViewController = LoginViewController()
        let loginViewModel = LoginViewModel(loginService: UserInfoAPI(), keychainUseCase: KeychainUseCase())
        loginViewController.viewModel = loginViewModel
        loginViewController.coordinator = self
        
        navigationController.pushViewController(loginViewController, animated: false)
    }
    
    func coordinateToDashboard() {
        let dashboardCoordinator = DashboardCoordinator(navigationController: navigationController)
        dashboardCoordinator.start()
    }
}
