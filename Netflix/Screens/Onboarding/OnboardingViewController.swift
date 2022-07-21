//
//  OnboardingViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.05.2022.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
    
    var viewModel: OnboardingViewModel?
    var coordinator: OnboardingCoordinator?
    
    private let disposeBag = DisposeBag()
    
    private let firstPageViewController = FirstPageViewController()
    private let secondPageViewController = SecondPageViewController()
    
    private lazy var pageController: UIPageViewController = {
        pageController = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        addChild(pageController)
        return pageController
    }()
    
    private var controllers = [UIViewController]()
    
    private let backgroundImageView = UIImageView(image: UIImage(named: Asset.Assets.onboarding.name))
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("SIGN IN", for: .normal)
        button.backgroundColor = Asset.Colors.onboardingButtons.color
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        guard let viewModel = viewModel else {
            return
        }
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: OnboardingViewModel) {
        let output = viewModel.transform(OnboardingViewModel.Input(
            signInButtonTap: signInButton.rx.tap.asObservable(),
            signUpButtonTap: secondPageViewController.signUpButton.rx.tap.asObservable()))
        
        output.signInButtonTap.drive(onNext: { [weak self] _ in
            self?.coordinator?.coordinateToLogin()
        }).disposed(by: disposeBag)
        
        output.signUpButtonTap.drive().disposed(by: disposeBag)
    }
    
    private func setupUI() {
        backgroundImageView.alpha = 0.4
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(signInButton)
        addChild(pageController)
        view.addSubview(pageController.view)
        
        controllers.append(firstPageViewController)
        controllers.append(secondPageViewController)
        
        if let firstViewController = controllers.first {
            pageController.setViewControllers([firstViewController], direction: .forward, animated: false)
        }
    }
    
    func setConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        signInButton.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.05)
            make.bottom.equalToSuperview().offset(-60)
        }
        
        pageController.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(signInButton.snp_topMargin)
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index =  controllers.firstIndex(of: viewController),
              index > 0 else {
            return nil
        }
        
        return controllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController),
              index < controllers.count - 1 else {
            return nil
        }
        
        return controllers[index + 1]
    }
}
