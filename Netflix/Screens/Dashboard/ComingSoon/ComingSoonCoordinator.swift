//
//  ComingSoonCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class ComingSoonCoordinator: Coordinator {
    
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let comingSoonViewController = ComingSoonViewController()
        navigationController?.pushViewController(comingSoonViewController, animated: false)
    }
    
    func coordinateToMovieDetails() {
        let movieDetailsCoordinator = MovieDetailsCoordinator(navigationController: navigationController!)
        coordinate(to: movieDetailsCoordinator)
    }
}
