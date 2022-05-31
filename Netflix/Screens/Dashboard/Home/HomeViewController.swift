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
    
    private let feedCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        feedCollection.delegate = self
        feedCollection.dataSource = self
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(latestFilm)
        view.addSubview(likeButton)
        view.addSubview(playButton)
        view.addSubview(feedCollection)
    }
    
    private func addNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(
            named: Asset.Assets.logoNetflix.name), style: .done, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(
            systemName: "person"), style: .done, target: self, action: nil)
    }
    
    private func setConstraints() {
        latestFilm.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
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
        feedCollection.snp.makeConstraints { make in
            make.top.equalTo(playButton.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for:
                                                        indexPath) as? HomeCollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let width = CGFloat(200)
           let height = CGFloat(250)
           
           return CGSize(width: width, height: height)
       }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

//    private let netflixButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(named: Asset.Assets.logoNetflix.name), for: .normal)
//        return button
//    }()

//    private let profileButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "person"), for: .normal)
//        button.imageView?.contentMode = .scaleAspectFit
//        button.tintColor = .white
//        return button
//    }()
//
