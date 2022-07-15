//
//  OnboardingCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import Foundation
import UIKit
 
class OnboardingCoordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let onboardingViewController = OnboardingViewController()
        navigationController.pushViewController(onboardingViewController, animated: false)
    }
}
