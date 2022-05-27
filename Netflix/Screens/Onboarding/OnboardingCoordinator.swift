//
//  OnboardingCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import Foundation
import UIKit
 
class OnboardingCoordinator {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let onboardingViewController = OnboardingViewController()
        window.rootViewController = onboardingViewController
        window.makeKeyAndVisible()
    }
}
