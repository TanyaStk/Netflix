//
//  DashboardViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import UIKit

class DashboardViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeViewController = HomeViewController()
        let comingSoonViewController = ComingSoonViewController()
        let favoritesViewController = FavoritesViewController()
        
        homeViewController.title = "Home"
        comingSoonViewController.title = "Coming Soon"
        favoritesViewController.title = "Favorites"
        
        homeViewController.tabBarItem.image = UIImage(systemName: "house")
        comingSoonViewController.tabBarItem.image = UIImage(systemName: "film")
        favoritesViewController.tabBarItem.image = UIImage(systemName: "heart")
        
        tabBar.tintColor = .white
        tabBar.barStyle = .black
        
        setViewControllers([homeViewController, comingSoonViewController, favoritesViewController], animated: false)
    }
}
