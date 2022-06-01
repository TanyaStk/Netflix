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
    
    private let popularMoviesLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular Movies"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let popularMoviesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popularMoviesCollection.delegate = self
        popularMoviesCollection.dataSource = self
        addSubviews()
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        addGradient()
    }
    
    private func addSubviews() {
        view.addSubview(latestFilm)
        view.addSubview(likeButton)
        view.addSubview(playButton)
        view.addSubview(popularMoviesCollection)
        popularMoviesCollection.addSubview(popularMoviesLabel)
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
        popularMoviesLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        popularMoviesCollection.snp.makeConstraints { make in
            make.top.equalTo(playButton.snp.bottom).offset(8)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(24)
            make.width.equalToSuperview()
        }
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = latestFilm.frame
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        latestFilm.layer.addSublayer(gradientLayer)
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
        let width = CGFloat(150)
        let height = CGFloat(200)
        
        return CGSize(width: width, height: height)
    }
}
