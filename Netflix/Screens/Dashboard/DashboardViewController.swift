//
//  DashboardViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.07.2022.
//

import UIKit

class DashboardViewController: UITabBarController {
    
    var coordinator: DashboardCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .white
        tabBar.barStyle = .black
    }

}
