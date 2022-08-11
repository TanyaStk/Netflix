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
import YouTubePlayer

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel?
    
    private let disposeBag = DisposeBag()
    
    private lazy var latestMovieImageView = HeadMovieCoverView()
    
    private lazy var trailerPlayer: YouTubePlayerView = {
        let player = YouTubePlayerView()
        player.isHidden = true
        return player
    }()
    
    private let noVideoProvidedFadingLabel: UILabel = {
        let label = UILabel()
        label.text = """
                    Sorry:(
                    No Video Provided
                    """
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()
    
    private let latestMovieTitle: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: FontFamily.Mansalva.regular.name, size: 36)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()
    
    private let latestMovieGenres: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
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
    
    private let stopPlayingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        button.setTitle("Stop", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.imageView?.snp.makeConstraints({ make in
            make.centerX.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview()
        })
        button.layer.cornerRadius = 8
        button.isHidden = true
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
        collectionView.alwaysBounceVertical = false
        return collectionView
    }()
    
    private func createLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 4
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
            top: spacing,
            leading: spacing,
            bottom: spacing,
            trailing: spacing)
        
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
            viewDidLoad: Observable.just(()),
            profileButtonTap: profileButton.rx.tap.asObservable(),
            likeButtonTap: likeButton.rx.tap.asObservable(),
            playButtonTap: playButton.rx.tap.asObservable(),
            movieCoverTap: popularMoviesCollection.rx.itemSelected.asObservable(),
            loadNextPage: popularMoviesCollection.rx.willDisplayCell.asObservable())
        )
        
        output.openProfile.drive().disposed(by: disposeBag)
        
        output.addLatestToFavorites.drive().disposed(by: disposeBag)
        
        output.isLatestMovieFavorite.drive(onNext: { [weak self] status in
            self?.isFavorite(status: status)
        })
        .disposed(by: disposeBag)
        
        output.showLatestMovie
            .drive(onNext: { [weak self] movie in
                self?.setupLatestMovieUI(for: movie)
            })
            .disposed(by: disposeBag)
        
        output.loadVideoKey.drive().disposed(by: disposeBag)

        output.videoKey.drive { [weak self] videoKey in
            if !videoKey.isEmpty {
                self?.changePlayerVisibility(on: false)
                self?.trailerPlayer.loadVideoID(videoKey)
            } else {
                self?.noVideoProvidedFadingLabel.isHidden = false
                UIView.animate(withDuration: 4.0, animations: { () -> Void in
                    self?.noVideoProvidedFadingLabel.alpha = 0.0
                })
            }
        }
        .disposed(by: disposeBag)
        
        stopPlayingButton.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                self?.changePlayerVisibility(on: true)
                self?.trailerPlayer.stop()
            }
            .disposed(by: disposeBag)
        
        output.loadMovies.drive().disposed(by: disposeBag)
        
        output.showPopularMovies
            .drive(self.popularMoviesCollection.rx.items(
                cellIdentifier: HomeCollectionViewCell.identifier,
                cellType: HomeCollectionViewCell.self)
            ) { _, data, cell in
                guard let url = URL(string: data.posterPath) else { return }
                cell.filmCoverImageView.sd_cancelCurrentImageLoad()
                cell.filmCoverImageView.sd_setImage(
                    with: url,
                    placeholderImage: nil,
                    options: .highPriority,
                    context: nil
                )
                data.isFavorite ? cell.addGlow() : cell.hideGlow()
            }
            .disposed(by: disposeBag)
        
        output.showMovieDetails.drive().disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func changePlayerVisibility(on status: Bool) {
        trailerPlayer.isHidden = status
        playButton.isHidden = !status
        stopPlayingButton.isHidden = status
    }
    
    private func isFavorite(status: Bool) {
        let imageName = status ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.tintColor = status ? Asset.Colors.loginButton.color : .white
    }
    
    private func setupLatestMovieUI(for movie: LatestMovie) {
        latestMovieTitle.text = movie.title
        latestMovieGenres.text = movie.genres.joined(separator: " \u{2022} ")
        
        if movie.adult {
            latestMovieImageView.filmCoverImageView.image = Asset.Assets.adultContentTitle.image
        } else {
            guard let url = URL(string: movie.posterPath) else { return }
            latestMovieImageView.filmCoverImageView.sd_setImage(
                with: url,
                placeholderImage: nil,
                options: .continueInBackground,
                context: nil
            )
        }
    }
    
    private func addSubviews() {
        view.addSubview(latestMovieImageView)
        view.addSubview(trailerPlayer)
        view.addSubview(latestMovieTitle)
        view.addSubview(noVideoProvidedFadingLabel)
        view.addSubview(latestMovieGenres)
        view.addSubview(netflixButton)
        view.addSubview(profileButton)
        view.addSubview(likeButton)
        view.addSubview(playButton)
        view.addSubview(stopPlayingButton)
        view.addSubview(popularMoviesLabel)
        view.addSubview(popularMoviesCollection)
    }
    
    private func setConstraints() {
        latestMovieImageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        trailerPlayer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
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
        
        latestMovieTitle.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.1)
            make.center.equalToSuperview()
        }
        
        noVideoProvidedFadingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-8)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        likeButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.05)
            make.centerY.equalTo(latestMovieImageView.snp.bottom)
            make.left.equalToSuperview().multipliedBy(0.2)
        }
        
        playButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.05)
            make.centerY.equalTo(latestMovieImageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        stopPlayingButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.05)
            make.centerY.equalTo(latestMovieImageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        latestMovieGenres.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(latestMovieTitle.snp.bottom).offset(-8)
            make.bottom.equalTo(playButton.snp.top).offset(-8)
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
