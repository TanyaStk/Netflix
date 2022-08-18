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
        let homeViewModel = HomeViewModel(coordinator: self,
                                          movieService: MoviesProvider(),
                                          userService: UserInfoProvider(),
                                          keychainUseCase: KeychainUseCase(),
                                          localStorageUseCase: LocalDataSourceUseCase())
        let homeViewController = HomeViewController()
        homeViewController.viewModel = homeViewModel
        
        navigationController?.pushViewController(homeViewController, animated: false)
    }
    
    func coordinateToProfile() {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController!)
        profileCoordinator.start()
    }
    
    func coordinateToMovieDetails(of movie: Int) {
        let movieDetailsCoordinator = MovieDetailsCoordinator(
            navigationController: navigationController!,
            movieId: movie)
        movieDetailsCoordinator.start()
    }
}
