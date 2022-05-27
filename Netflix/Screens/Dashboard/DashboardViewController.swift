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
        
        self.setViewControllers([homeViewController, comingSoonViewController, favoritesViewController], animated: false)
        
        guard let items = self.tabBar.items else { return }
        
        let images = [Asset.Assets.home.name, Asset.Assets.comingSoon.name, Asset.Assets.favorites.name]

        for ind in 0...2 {
            items[ind].image = UIImage(named: images[ind])
        }
        self.tabBar.tintColor = .white
        self.tabBar.backgroundColor = .clear
    }
}
