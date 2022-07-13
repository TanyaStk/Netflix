//
//  ProfileViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 12.07.2022.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    
    private let profileLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageView?.snp.makeConstraints({ make in
            make.width.height.equalToSuperview()
        })
        button.tintColor = .white
        return button
    }()
    
    lazy var navigationStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        [self.profileLabel,
         self.closeButton].forEach { stack.addArrangedSubview($0) }
        return stack
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.Assets.logoNetflixShort.image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Tanya Samostroyenko"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let memberLabel: UILabel = {
        let label = UILabel()
        label.text = "MEMBER"
        label.backgroundColor = Asset.Colors.inputFields.color.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var nameStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillProportionally
        [self.nameLabel,
         self.memberLabel].forEach { stack.addArrangedSubview($0) }
        return stack
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "tanyasamastr@gmail.com"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let totalPointsAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "123"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return label
    }()
    
    private let totalPointsLabel: UILabel = {
        let label = UILabel()
        label.text = "TOTAL POINTS"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    
    lazy var totalPointsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        [self.totalPointsAmountLabel,
         self.totalPointsLabel].forEach { stack.addArrangedSubview($0) }
        return stack
    }()
    
    private let watchedMoviesAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "6"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return label
    }()
    
    private let watchedMoviesLabel: UILabel = {
        let label = UILabel()
        label.text = "MOVIES WATCHED"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    
    lazy var watchedMoviesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        [self.watchedMoviesAmountLabel,
         self.watchedMoviesLabel].forEach { stack.addArrangedSubview($0) }
        return stack
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("LOGOUT", for: .normal)
        button.backgroundColor = Asset.Colors.onboardingButtons.color
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(navigationStackView)
        view.addSubview(avatarImageView)
        view.addSubview(nameStackView)
        view.addSubview(emailLabel)
        view.addSubview(totalPointsStackView)
        view.addSubview(watchedMoviesStackView)
        view.addSubview(logoutButton)
    }
    
    private func setConstraints() {
        navigationStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-8)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.1)
            make.height.equalTo(closeButton.snp.width)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(avatarImageView.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(navigationStackView.snp.bottom).offset(8)
        }

        memberLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        nameStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.95)
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom).offset(8)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.05)
            make.top.equalTo(nameLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        totalPointsStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.08)
            make.left.equalToSuperview()
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
        }
        
        watchedMoviesStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.08)
            make.right.equalToSuperview()
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.08)
            make.bottom.equalToSuperview()
        }

    }
}
