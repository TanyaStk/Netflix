//
//  ComingSoonViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SDWebImage

class ComingSoonViewController: UIViewController {
    
    var viewModel: ComingSoonViewModel?
    
    private let disposeBag = DisposeBag()
    
    private let searchController: UISearchController = {
        let controller = UISearchController()
        controller.searchBar.placeholder = "Search"
        controller.searchBar.barStyle = .black
        return controller
    }()
    
    private lazy var searchResultsCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(MoviesCollectionViewCell.self,
                                forCellWithReuseIdentifier: MoviesCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.isHidden = true
        return collectionView
    }()

    private lazy var upcomingMoviesCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(MoviesCollectionViewCell.self,
                                forCellWithReuseIdentifier: MoviesCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .clear
        
        addSubviews()
        setConstraints()
        
        guard let viewModel = viewModel else {
            return
        }
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: ComingSoonViewModel) {
        let output = viewModel.transform(ComingSoonViewModel.Input(
            isViewLoaded: Observable.just(true),
            searchQuery: navigationItem.searchController!.searchBar.rx.text.orEmpty.asObservable(),
            cancelSearching: navigationItem.searchController!.searchBar.rx.cancelButtonClicked.asObservable(),
            loadUpcomingNextPage: upcomingMoviesCollection.rx.willDisplayCell.asObservable(),
            loadSearchingNextPage: searchResultsCollection.rx.willDisplayCell.asObservable(),
            upcomingMovieCoverTap: upcomingMoviesCollection.rx.itemSelected.asObservable(),
            searchingResultsMovieCoverTap: searchResultsCollection.rx.itemSelected.asObservable()
        ))
        
        output.loadMovies.subscribe().disposed(by: disposeBag)
        
        output.showUpcomingMovies.drive(self.upcomingMoviesCollection.rx.items(
            cellIdentifier: MoviesCollectionViewCell.identifier,
            cellType: MoviesCollectionViewCell.self)
        ) { _, data, cell in
            guard let url = URL(string: data.posterPath) else { return }
            cell.filmCoverImageView.sd_setImage(with: url)
        }
        .disposed(by: disposeBag)
        
        output.isHiddenUpcoming.drive(onNext: { [weak self] status in
            self?.changeVisibility(isUpcomingHidden: status,
                                   isSearchingResultsHidden: !status)
        })
        .disposed(by: disposeBag)

        output.showSearchingResults.drive(self.searchResultsCollection.rx.items(
            cellIdentifier: MoviesCollectionViewCell.identifier,
            cellType: MoviesCollectionViewCell.self)
        ) { _, data, cell in
            guard let url = URL(string: data.posterPath) else { return }
            cell.filmCoverImageView.sd_setImage(with: url)
        }
        .disposed(by: disposeBag)
        
        Driver.merge(output.showUpcomingMovieDetails,
                     output.showSearchingMovieDetails)
        .drive()
        .disposed(by: disposeBag)
        
        output.error.drive(onNext: { error in
            print(error)
        })
        .disposed(by: disposeBag)
    }
    
    func scrollToTop() {
        upcomingMoviesCollection.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        searchResultsCollection.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    private func changeVisibility(isUpcomingHidden: Bool, isSearchingResultsHidden: Bool) {
        upcomingMoviesCollection.isHidden = isUpcomingHidden
        searchResultsCollection.isHidden = isSearchingResultsHidden
    }
    
    private func addSubviews() {
        view.addSubview(upcomingMoviesCollection)
        view.addSubview(searchResultsCollection)
    }
    
    private func setConstraints() {
        upcomingMoviesCollection.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
        }
        
        searchResultsCollection.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 10
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        section.interGroupSpacing = spacing

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ComingSoonViewController: UITabBarControllerDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Coming Soon" {
            print("Coming soon selected")
//            scrollToTop()
        }
    }
}
