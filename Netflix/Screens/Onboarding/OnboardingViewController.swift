//
//  OnboardingViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.05.2022.
//

import UIKit
import SnapKit

class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private lazy var pageController: UIPageViewController = {
        pageController = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        addChild(pageController)
        return pageController
    }()
    var controllers = [UIViewController]()

    private let backgroundImageView = UIImageView(image: UIImage(named: Asset.Assets.onboarding.name))
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("SIGN IN", for: .normal)
        button.backgroundColor = Asset.Colors.onboardingButtons.color
        button.setTitleColor(.white, for: .normal)
        button.addTarget(OnboardingViewController.self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped(sender: UIButton) {
        print("Hello")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.alpha = 0.4
        addSubviews()

        if let firstViewController = controllers.first {
            pageController.setViewControllers([firstViewController], direction: .forward, animated: false)
        }
        setConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(signInButton)
        addChild(pageController)
        view.addSubview(pageController.view)
        let firstPageViewController = FirstPageViewController()
        let secondPageViewController = SecondPageViewController()

        controllers.append(firstPageViewController)
        controllers.append(secondPageViewController)
    }

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
