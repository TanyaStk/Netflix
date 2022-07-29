//
//  DashboardCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class DashboardCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let dashboardController = DashboardViewController()
        dashboardController.coordinator = self
        
        let homeNavigationController = UINavigationController()
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home",
                                                           image: UIImage(systemName: "house"),
                                                           tag: 0)
        let homeCoordinator = HomeCoordinator(navigationController: homeNavigationController)
        
        let comingSoonNavigationController = UINavigationController()
        comingSoonNavigationController.tabBarItem = UITabBarItem(title: "Coming Soon",
                                                                 image: UIImage(systemName: "film"),
                                                                 tag: 1)
        let comingSoonCoordinator = ComingSoonCoordinator(navigationController: comingSoonNavigationController)
        
        let favoritesNavigationController =  UINavigationController()
        favoritesNavigationController.tabBarItem = UITabBarItem(title: "Favorites",
                                                                image: UIImage(systemName: "heart"),
                                                                tag: 2)
        let favoritesCoordinator = FavoritesCoordinator(navigationController: favoritesNavigationController)
        
        dashboardController.viewControllers = [homeNavigationController,
                                                       comingSoonNavigationController,
                                                       favoritesNavigationController]
        
        dashboardController.modalPresentationStyle = .fullScreen
        navigationController.present(dashboardController, animated: false)
        
        homeCoordinator.start()
        comingSoonCoordinator.start()
        favoritesCoordinator.start()
    }
}
