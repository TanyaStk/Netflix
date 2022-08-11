//
//  ComingSoonCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class ComingSoonCoordinator: Coordinator {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let comingSoonViewController = ComingSoonViewController()
        let comingSoonViewModel = ComingSoonViewModel(
            coordinator: self,
            movieService: MoviesProvider(),
            userService: UserInfoProvider(),
            keychainUseCase: KeychainUseCase()
        )
        comingSoonViewController.viewModel = comingSoonViewModel
        
        navigationController?.pushViewController(comingSoonViewController, animated: false)
    }
    
    func coordinateToMovieDetails(of movie: Int) {
        let movieDetailsCoordinator = MovieDetailsCoordinator(
            navigationController: navigationController!,
            movieId: movie)
        movieDetailsCoordinator.start()
    }
}
