//
//  SplashViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 24.05.2022.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SplashViewController: UIViewController {
    
    var viewModel: SplashViewModel?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        guard let viewModel = viewModel else {
            return
        }
        bind(to: viewModel)
    }
    
   private func bind(to viewModel: SplashViewModel) {
        let output = viewModel.transform(SplashViewModel.Input(isAppLoaded: Observable.just(true)))

       output.error.drive().disposed(by: disposeBag)        
       output.success.drive().disposed(by: disposeBag)
    }
    
    private func setupUI() {
        navigationController?.navigationBar.barTintColor = .clear
        view.backgroundColor = .black
        let logoImageView = UIImageView(image: Asset.Assets.logoNetflixShort.image)
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
