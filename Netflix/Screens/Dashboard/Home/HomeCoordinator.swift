//
//  HomeCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class HomeCoordinator: Coordinator {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeViewController = HomeViewController()
        navigationController?.pushViewController(homeViewController, animated: false)
    }
    
    func coordinateToProfile() {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController!)
        profileCoordinator.start()
    }
    
    func coordinateToMovieDetails() {
        let movieDetailsCoordinator = MovieDetailsCoordinator(navigationController: navigationController!)
        movieDetailsCoordinator.start()
    }
}
