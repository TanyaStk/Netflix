//
//  DashboardCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class DashboardCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarController = UITabBarController()
        
        let homeNavigationController = UINavigationController(rootViewController: HomeViewController())
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        
        let comingSoonNavigationController = UINavigationController(rootViewController: ComingSoonViewController())
        let comingSoonCoordinator = ComingSoonCoordinator(navigationController: navigationController)
        
        let favoritesNavigationController =  UINavigationController(rootViewController: FavoritesViewController())
        let favoritesCoordinator = FavoritesCoordinator(navigationController: navigationController)
        
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home",
                                                           image: UIImage(systemName: "house"),
                                                           tag: 0)
        comingSoonNavigationController.tabBarItem = UITabBarItem(title: "Coming Soon",
                                                                 image: UIImage(systemName: "film"),
                                                                 tag: 1)
        favoritesNavigationController.tabBarItem = UITabBarItem(title: "Favorites",
                                                                image: UIImage(systemName: "heart"),
                                                                tag: 2)
        
        tabBarController.tabBar.tintColor = .white
        tabBarController.tabBar.barStyle = .black
        
        tabBarController.viewControllers = [homeNavigationController,
                                            comingSoonNavigationController,
                                            favoritesNavigationController]
        
        tabBarController.modalPresentationStyle = .fullScreen
        navigationController.present(tabBarController, animated: false)
        
        coordinate(to: homeCoordinator)
        coordinate(to: comingSoonCoordinator)
        coordinate(to: favoritesCoordinator)
    }
}
