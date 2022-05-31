//
//  HomeViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    private let latestFilm: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Asset.Assets.filmCover.name)
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setTitle("Like", for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(latestFilm)
        view.addSubview(likeButton)
        view.addSubview(playButton)
        setConstraints()
    }
    
    func setConstraints() {
        latestFilm.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        likeButton.snp.makeConstraints { make in
            make.width.height.equalToSuperview().multipliedBy(0.3)
            make.centerY.equalTo(latestFilm.snp.bottom)
            make.left.equalToSuperview().multipliedBy(0.2)
        }
        playButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.05)
            make.centerY.equalTo(latestFilm.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
}
