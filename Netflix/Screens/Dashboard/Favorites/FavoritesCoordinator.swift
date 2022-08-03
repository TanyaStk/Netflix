//
//  FavoritesCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class FavoritesCoordinator: Coordinator {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let favoritesViewController = FavoritesViewController()
        let favoritesViewModel = FavoritesViewModel(coordinator: self,
                                                    service: UserInfoProvider(),
                                                    keychainUseCase: KeychainUseCase())
        favoritesViewController.viewModel = favoritesViewModel
        
        navigationController?.pushViewController(favoritesViewController, animated: true)
    }
    
    func coordinateToComingSoon() {
        let comingSoonCoordinator = ComingSoonCoordinator(navigationController: navigationController!)
        comingSoonCoordinator.start()
    }
    
    func coordinateToMovieDetails(of movie: Int) {
        let movieDetailsCoordinator = MovieDetailsCoordinator(
            navigationController: navigationController!,
            movieId: movie)
        movieDetailsCoordinator.start()
    }

}
