//
//  AppCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let splashCoordinator = SplashCoordinator(navigationController: navigationController)
        splashCoordinator.start()
    }
}
