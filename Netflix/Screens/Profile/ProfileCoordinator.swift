//
//  ProfileCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 14.07.2022.
//

import Foundation
import UIKit

class ProfileCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let profileViewController = ProfileViewController()
        navigationController.present(profileViewController, animated: false)
    }
    
    func dismissProfile() {
        navigationController.dismiss(animated: false)
    }
}
