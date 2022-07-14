//
//  MovieDetailsCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class MovieDetailsCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let movieDetailsViewController = MovieDetailsViewController()
        navigationController.present(movieDetailsViewController, animated: false)
    }
    
    func dismissProfile() {
        navigationController.dismiss(animated: false)
    }
}
