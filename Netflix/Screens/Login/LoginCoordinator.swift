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
        let loginViewModel = LoginViewModel(coordinator: self,
                                            loginService: UserInfoProvider(),
                                            keychainUseCase: KeychainUseCase())
        loginViewController.viewModel = loginViewModel
        loginViewController.modalPresentationStyle = .fullScreen
        
        navigationController.present(loginViewController, animated: false)
    }
    
    func coordinateToDashboard() {
        navigationController.dismiss(animated: true)
        
        let dashboardCoordinator = DashboardCoordinator(navigationController: navigationController)
        dashboardCoordinator.start()
    }
}
