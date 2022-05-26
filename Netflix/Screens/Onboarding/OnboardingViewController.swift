//
//  OnboardingViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.05.2022.
//

import UIKit
import SnapKit

class OnboardingViewController: UIViewController {
    
    private let backgroundImageView = UIImageView(image: UIImage(named: Asset.Assets.onboarding.name))
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("SIGN IN", for: .normal)
        button.backgroundColor = Asset.Colors.onboardingButtons.color
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Trying to join NetflixDB?"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = """
            You can’t sign up for Netflix in the app. We know it’s a hassle.\
            After you’re a member, you can start watching in the app.
            Scroll > to learn more
            """
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundImageView)
        view.addSubview(signInButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        backgroundImageView.alpha = 0.4
        setConstraints()
    }
    
    func setConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.05)
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottomMargin).offset(12)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        signInButton.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.05)
            make.bottom.equalToSuperview().offset(-60)
        }
    }
}
