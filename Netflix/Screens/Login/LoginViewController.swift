//
//  LoginViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 30.05.2022.
//

import UIKit
import Lottie
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let logoImage = UIImageView(image: UIImage(named: Asset.Assets.logoNetflixLong.name))
    
    private let animationView: AnimationView = {
        let animationView = AnimationView(animation: Animation.named("LottieSpinner"))
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.isHidden = true
        return animationView
    }()
    
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
        addSubviews()
        setConstraints()
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { _ in
                self.keyboardWillShow()
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { _ in
                self.keyboardWillHide()
            })
            .disposed(by: disposeBag)
    }
    
    private func keyboardWillShow() {
        stackView.snp.updateConstraints { make in
            make.centerY.equalToSuperview().offset(-10)
        }
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func keyboardWillHide() {
        stackView.snp.updateConstraints { make in
            make.centerY.equalToSuperview()
        }
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })

    }
    
    private func showAnimation() {
        stackView.isHidden = true
        animationView.isHidden = false
        animationView.play()
    }
    
    private func hideAnimation() {
        animationView.isHidden = true
        animationView.stop()
    }
    
    private func addSubviews() {
        view.addSubview(logoImage)
        view.addSubview(stackView)
        view.addSubview(animationView)
        stackView.addArrangedSubview(loginField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(guestModeButton)
    }
    
    private func setConstraints() {
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
