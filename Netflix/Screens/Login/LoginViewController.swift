//
//  LoginViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 30.05.2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let logoImage = UIImageView(image: UIImage(named: Asset.Assets.logoNetflixLong.name))
    
    private let loginField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = Asset.Colors.inputFields.color
        textField.layer.cornerRadius = 8
        textField.textColor = Asset.Colors.loginTexts.color
        textField.font = .boldSystemFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.attributedPlaceholder = NSAttributedString(
            string: "E-mail/Phone",
            attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.loginTexts.color.withAlphaComponent(0.6)])
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
        return textField
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = Asset.Colors.inputFields.color
        textField.layer.cornerRadius = 8
        textField.textColor = Asset.Colors.loginTexts.color
        textField.font = .boldSystemFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.loginTexts.color.withAlphaComponent(0.6)])
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(Asset.Colors.loginButton.color, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = Asset.Colors.loginButton.color.cgColor
        return button
    }()
    
    private let guestModeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Guest Mode", for: .normal)
        button.setTitleColor(Asset.Colors.loginTexts.color, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.axis = .vertical
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoImage)
        view.addSubview(stackView)
        stackView.addArrangedSubview(loginField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(guestModeButton)
        setConstraints()
    }
    func setConstraints() {
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.centerX.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
            make.center.equalToSuperview()
        }
        loginField.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.2)
            make.trailing.equalToSuperview().inset(16)
        }
        passwordField.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        loginButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        guestModeButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
    }
}
