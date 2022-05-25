//
//  SplashViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 24.05.2022.
//

import Foundation
import UIKit
import SnapKit

class SplashViewController: ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        let logoImageView = UIImageView(image: UIImage(named: Asset.Assets.logoNetflix.name))
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
