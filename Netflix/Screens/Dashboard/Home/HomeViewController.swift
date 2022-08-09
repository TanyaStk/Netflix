//
//  HomeViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SDWebImage

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel?
    
    private let disposeBag = DisposeBag()
    
    private lazy var latestFilmImageView = LatestFilmView()
    
    private let latestFilmTitle: UILabel = {
        let label = UILabel()
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
        button.setImage(Asset.Assets.logoNetflixShort.image, for: .normal)
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
        button.imageView?.snp.makeConstraints({ make in
            make.centerX.equalToSuperview().multipliedBy(0.7)
            make.centerY.equalToSuperview()
        })
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.imageView?.snp.makeConstraints({ make in
            make.centerX.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview()
        })
        button.layer.cornerRadius = 8
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
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var popularMoviesCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(HomeCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.4),
            heightDimension: .fractionalHeight(1.0))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 4,
            leading: 4,
            bottom: 4,
            trailing: 4)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setConstraints()
        
        navigationController?.navigationBar.isHidden = true
        
        guard let viewModel = viewModel else {
            return
        }
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: HomeViewModel) {
        let output = viewModel.transform(HomeViewModel.Input(
            profileButtonTap: profileButton.rx.tap.asObservable(),
            likeButtonTap: likeButton.rx.tap.asObservable(),
            movieCoverTap: popularMoviesCollection.rx.itemSelected.asObservable())
        )
        
        output.openProfile.drive().disposed(by: disposeBag)
        
        output.addLatestToFavorites.drive().disposed(by: disposeBag)
        
        output.isLatestMovieFavorite.drive(onNext: { [weak self] status in
            self?.isFavorite(status: status)
        })
        .disposed(by: disposeBag)
        
        output.showLatestMovie
            .drive(onNext: { [weak self] movie in
                self?.latestFilmTitle.text = movie.title
                
                guard let url = URL(string: movie.posterPath) else { return }
                self?.latestFilmImageView.filmCoverImageView.sd_setImage(with: url)
            })
            .disposed(by: disposeBag)
        
        output.loadMovies.drive().disposed(by: disposeBag)
        
        output.showPopularMovies
            .drive(self.popularMoviesCollection.rx.items(
                cellIdentifier: HomeCollectionViewCell.identifier,
                cellType: HomeCollectionViewCell.self)
            ) { _, data, cell in
                guard let url = URL(string: data.posterPath) else { return }
                cell.filmCoverImageView.sd_setImage(with: url)
                data.isFavorite ? cell.addGlow() : cell.hideGlow()
            }
            .disposed(by: disposeBag)
        
        output.showMovieDetails.drive().disposed(by: disposeBag)
        
        output.error.drive(onNext: { error in
            print(error)
        })
        .disposed(by: disposeBag)
    }
    
    private func isFavorite(status: Bool) {
        let imageName = status ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.tintColor = status ? Asset.Colors.loginButton.color : .white
    }
    
    private func addSubviews() {
        view.addSubview(latestFilmImageView)
        view.addSubview(latestFilmTitle)
        view.addSubview(netflixButton)
        view.addSubview(profileButton)
        view.addSubview(likeButton)
        view.addSubview(playButton)
        view.addSubview(popularMoviesLabel)
        view.addSubview(popularMoviesCollection)
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
            make.width.equalToSuperview().multipliedBy(0.1)
            make.height.equalTo(profileButton.snp.width)
            make.centerY.equalTo(netflixButton.snp.centerY)
            make.right.equalToSuperview().offset(-8)
        }
        
        likeButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.05)
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
            make.height.equalToSuperview().multipliedBy(0.03)
            make.top.equalTo(likeButton.snp.bottom).offset(8)
            
        }
        
        popularMoviesCollection.snp.makeConstraints { make in
            make.top.equalTo(popularMoviesLabel.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
        }
    }
}
