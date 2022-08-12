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
    
    var viewModel: LoginViewModel?
    
    private let disposeBag = DisposeBag()
    
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
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
        
        textField.backgroundColor = Asset.Colors.inputFields.color
        textField.layer.cornerRadius = 8
        textField.textColor = Asset.Colors.loginTexts.color
        textField.font = .boldSystemFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.attributedPlaceholder = NSAttributedString(
            string: "E-mail/Phone",
            attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.loginTexts.color.withAlphaComponent(0.6)])
        return textField
    }()
    
    private let showPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show", for: .normal)
        button.setTitleColor(Asset.Colors.loginTexts.color, for: .normal)
        button.tintColor = .clear
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 8)
        return button
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always

        textField.backgroundColor = Asset.Colors.inputFields.color
        textField.layer.cornerRadius = 8
        textField.textColor = Asset.Colors.loginTexts.color
        textField.font = .boldSystemFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.loginTexts.color.withAlphaComponent(0.6)])
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(Asset.Colors.loginButton.color, for: .normal)
        button.setTitleColor(Asset.Colors.loginTexts.color, for: .disabled)
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
    
    private let loginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.axis = .vertical
        return stackView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton()
        button.setTitle("RETRY", for: .normal)
        button.backgroundColor = Asset.Colors.onboardingButtons.color
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var errorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.backgroundColor = .black
        [self.errorLabel,
         self.retryButton].forEach { stackView.addArrangedSubview($0) }
        stackView.isHidden = true
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setConstraints()
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.keyboardWillShow(notification: notification)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.keyboardWillHide()
            })
            .disposed(by: disposeBag)
        
        guard let viewModel = viewModel else {
            return
        }
        bind(to: viewModel)
    }
    
    func bind(to viewModel: LoginViewModel) {
        let output = viewModel.transform(LoginViewModel.Input(
            login: loginField.rx.text.orEmpty.asObservable(),
            password: passwordField.rx.text.orEmpty.asObservable(),
            loginButtonTap: loginButton.rx.tap.asObservable(),
            showPasswordButtonTap: showPasswordButton.rx.tap.asObservable(),
            retryButtonTap: retryButton.rx.tap.asObservable()
        ))
              
        output.changePasswordVisibility.drive().disposed(by: disposeBag)
        
        output.isPasswordHidden.drive { [weak self] status in
            self?.passwordField.isSecureTextEntry = status
            status ? (self?.showPasswordButton.setTitle("Show", for: .normal)) :
            (self?.showPasswordButton.setTitle("Hide", for: .normal))
        }
        .disposed(by: disposeBag)
        
        output.isLoginButtonEnabled
            .drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.loginLoading.drive(onNext: { [weak self] in
            self?.setLoading(visible: $0)
        }).disposed(by: disposeBag)

        output.error.drive(onNext: {[weak self] (error) in
            self?.showErrorView(with: error)
        }).disposed(by: disposeBag)
        
        output.showInputFields.drive(onNext: { [weak self] in
            self?.errorStackView.isHidden = $0
            self?.loginStackView.isHidden = !$0
        })
        .disposed(by: disposeBag)
        
        output.success.drive().disposed(by: disposeBag)
    }
    
    private func showErrorView(with error: String) {
        errorLabel.text = error
        errorStackView.isHidden = false
        loginStackView.isHidden = true
    }
    
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedStackViewFrame = loginStackView.convert(loginStackView.frame, to: loginStackView.superview)
        let stackViewBottomY = convertedStackViewFrame.origin.y + convertedStackViewFrame.size.height
        
        if stackViewBottomY > keyboardTopY {
            let overlappedSpace = -(stackViewBottomY - keyboardTopY) / 2
            loginStackView.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(overlappedSpace)
            }
            view.setNeedsLayout()
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func keyboardWillHide() {
        loginStackView.snp.updateConstraints { make in
            make.centerY.equalToSuperview()
        }
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })

    }
    
    private func setLoading(visible: Bool) {
        visible ? showAnimation() : hideAnimation()
    }
    
    private func showAnimation() {
        loginStackView.isHidden = true
        animationView.isHidden = false
        animationView.play()
    }
    
    private func hideAnimation() {
        loginStackView.isHidden = false
        animationView.isHidden = true
        animationView.stop()
    }
    
    private func addSubviews() {
        view.addSubview(logoImage)
        view.addSubview(loginStackView)
        view.addSubview(animationView)
        view.addSubview(errorStackView)
        
        passwordField.rightView = showPasswordButton
        passwordField.rightViewMode = .always
        
        loginStackView.addArrangedSubview(loginField)
        loginStackView.addArrangedSubview(passwordField)
        loginStackView.addArrangedSubview(loginButton)
        loginStackView.addArrangedSubview(guestModeButton)
    }
    
    private func setConstraints() {
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.centerX.equalToSuperview()
        }
        
        loginStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
            make.center.equalToSuperview()
        }
        
        loginField.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        passwordField.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        loginButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        guestModeButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        errorStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
    }
}

extension UIViewController {
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action:    #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}
