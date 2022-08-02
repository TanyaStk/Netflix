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
        let controller = UISearchController(searchResultsController: SearchViewController())
        controller.searchBar.placeholder = "Search"
        controller.searchBar.barStyle = .black
        return controller
    }()
    
    private lazy var upcomingMoviesCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(UpcomingMoviesCollectionViewCell.self,
                                forCellWithReuseIdentifier: UpcomingMoviesCollectionViewCell.identifier)
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
            searchQuery: self.navigationItem.searchController!.searchBar.rx.text.orEmpty.asObservable(),
            movieCoverTap: upcomingMoviesCollection.rx.itemSelected.asObservable()
        ))
        
        output.loadMovies.subscribe().disposed(by: disposeBag)
        
        output.showUpcomingMovies.drive(self.upcomingMoviesCollection.rx.items(
            cellIdentifier: UpcomingMoviesCollectionViewCell.identifier,
            cellType: UpcomingMoviesCollectionViewCell.self)
        ) { _, data, cell in
            guard let url = URL(string: data.posterPath) else { return }
            cell.filmCoverImageView.sd_setImage(with: url)
        }
        .disposed(by: disposeBag)
        
        output.showSearchingResults.drive().disposed(by: disposeBag)
        
//        output.showSearchingResults.drive(self.upcomingMoviesCollection.rx.items(
//            cellIdentifier: UpcomingMoviesCollectionViewCell.identifier,
//            cellType: UpcomingMoviesCollectionViewCell.self)
//        ) { _, data, cell in
//            guard let url = URL(string: data.posterPath) else { return }
//            cell.filmCoverImageView.sd_setImage(with: url)
//        }
//        .disposed(by: disposeBag)
        
        output.showMovieDetails.drive().disposed(by: disposeBag)
        
        output.error.drive(onNext: { error in
            print(error)
        })
        .disposed(by: disposeBag)
    }
    
    private func addSubviews() {
        view.addSubview(upcomingMoviesCollection)
    }
    
    private func setConstraints() {
        upcomingMoviesCollection.snp.makeConstraints { make in
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
