//
//  MovieDetailsCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class MovieDetailsCoordinator: Coordinator {

    private let navigationController: UINavigationController
    private let movieId: Int
    
    init(navigationController: UINavigationController,
         movieId: Int) {
        self.navigationController = navigationController
        self.movieId = movieId
    }
    
    func start() {
        let movieDetailsViewModel = MovieDetailsViewModel(coordinator: self,
                                                          movieService: MoviesProviderAPI(),
                                                          userService: UserInfoProvider(),
                                                          keychainUseCase: KeychainUseCase(),
                                                          movieId: movieId)
        
        let movieDetailsViewController = MovieDetailsViewController()
        movieDetailsViewController.viewModel = movieDetailsViewModel
        movieDetailsViewController.modalPresentationStyle = .fullScreen
        
        navigationController.present(movieDetailsViewController, animated: true)
    }
    
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
}
