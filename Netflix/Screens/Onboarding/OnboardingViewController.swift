//
//  OnboardingViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.05.2022.
//

import UIKit
import SnapKit

class OnboardingViewController: UIViewController {
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("SIGN IN", for: .normal)
        button.backgroundColor = Asset.Colors.onboardingButtons.color
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView(image: UIImage(named: Asset.Assets.onboarding.name))
        view.addSubview(backgroundImageView)
        view.addSubview(signInButton)
        backgroundImageView.alpha = 0.5
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        signInButton.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.05)
            make.bottom.equalToSuperview().offset(-60)
        }
    }
}
