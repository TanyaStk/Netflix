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
        navigationController.pushViewController(splashViewController, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let dashboardCoordinator = DashboardCoordinator(navigationController: self.navigationController)
            dashboardCoordinator.start()
        }
    }
}
