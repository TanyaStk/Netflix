//
//  SplashCoordinator.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 24.05.2022.
//

import Foundation
import UIKit

class SplashCoordinator {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let splashVCc = SplashViewController()
        window.rootViewController = splashVCc
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.window.rootViewController = ViewController()
            self.window.makeKeyAndVisible()
        }
    }
    
}
