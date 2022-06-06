//
//  HomeViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    private lazy var latestFilmImageView = LatestFilmView()
    
    private let latestFilmTitle: UILabel = {
        let label = UILabel()
        label.text = "Never Have I Ever"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: FontFamily.Mansalva.regular.name, size: 48)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()
    
    private let netflixButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Asset.Assets.logoNetflixShort.name), for: .normal)
        button.imageView?.snp.makeConstraints({ make in
            make.width.height.equalToSuperview()
        })
        return button
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.fill"), for: .normal)
        button.imageView?.snp.makeConstraints({ make in
            make.width.height.equalToSuperview()
        })
        button.tintColor = .white
        return button
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
        button.contentMode = .scaleAspectFit
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
    
    private lazy var popularMoviesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HomeCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setConstraints()
    }

    private func addSubviews() {
        view.addSubview(latestFilmImageView)
        view.addSubview(latestFilmTitle)
        view.addSubview(netflixButton)
        view.addSubview(profileButton)
        view.addSubview(likeButton)
        view.addSubview(playButton)
        view.addSubview(popularMoviesCollection)
        popularMoviesCollection.addSubview(popularMoviesLabel)
    }
    
    private func setConstraints() {
        latestFilmImageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        latestFilmTitle.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.2)
            make.center.equalToSuperview()
        }
        netflixButton.snp.makeConstraints { make in
            make.width.height.equalToSuperview().multipliedBy(0.1)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-8)
            make.left.equalToSuperview().offset(8)
        }
        profileButton.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.05)
            make.width.equalToSuperview().multipliedBy(0.1)
            make.centerY.equalTo(netflixButton.snp.centerY)
            make.right.equalToSuperview().offset(-8)
        }
        likeButton.snp.makeConstraints { make in
            make.width.height.equalToSuperview().multipliedBy(0.3)
            make.centerY.equalTo(latestFilmImageView.snp.bottom)
            make.left.equalToSuperview().multipliedBy(0.2)
        }
        playButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.05)
            make.centerY.equalTo(latestFilmImageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        popularMoviesLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        popularMoviesCollection.snp.makeConstraints { make in
            make.top.equalTo(playButton.snp.bottom).offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(24)
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
        let width = CGFloat(150)
        let height = CGFloat(200)
        
        return CGSize(width: width, height: height)
    }
}
