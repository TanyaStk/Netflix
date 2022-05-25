//
//  OnboardingViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.05.2022.
//

import UIKit
import SnapKit

class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView(image: UIImage(named: Asset.Assets.onboarding.name))
        view.addSubview(backgroundImageView)
        backgroundImageView.backgroundColor = .orange
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
}
