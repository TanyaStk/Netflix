//
//  FavoritesViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SDWebImage

class FavoritesViewController: UIViewController {

    var viewModel: FavoritesViewModel?
    
    private let disposeBag = DisposeBag()
    
    private let favoritesTable: UITableView = {
        let table = UITableView()
        table.register(FavoritesTableViewCell.self,
                       forCellReuseIdentifier: FavoritesTableViewCell.identifier)
        table.rowHeight = UITableView.automaticDimension
        table.backgroundColor = .clear
        table.isHidden = true
        return table
    }()
    
    private let emptyTitleListLabel: UILabel = {
        let label = UILabel()
        label.text = "Ohhh... Your favorites list is empty!"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let emptySubtitleListLabel: UILabel = {
        let label = UILabel()
        label.text = """
                But it doesn't have to be.
                Explore coming soon to add movies
                to favorites & show them here.
                """
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let switchButton: UIButton = {
        let button = UIButton()
        button.setTitle("SWITCH TO COMING SOON", for: .normal)
        button.backgroundColor = Asset.Colors.onboardingButtons.color
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let ifFavoritesEmptyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.isHidden = true
        return stackView
    }()
    
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

    private func bind(to viewModel: FavoritesViewModel) {
        let output = viewModel.transform(FavoritesViewModel.Input(
            isViewLoaded: Observable.just(true),
            switchButtonTap: switchButton.rx.tap.asObservable(),
            deleteFromFavorites: favoritesTable.rx.itemDeleted.asObservable(),
            movieCoverTap: favoritesTable.rx.itemSelected.asObservable()
        ))
        
        favoritesTable.rx.setDelegate(self).disposed(by: disposeBag)
        
        output.showingTrigger.subscribe().disposed(by: disposeBag)
        
        output.showFavoriteMovies
            .drive(self.favoritesTable.rx.items(
            cellIdentifier: FavoritesTableViewCell.identifier,
            cellType: FavoritesTableViewCell.self)
        ) { _, data, cell in
            guard let url = URL(string: data.posterPath) else { return }
            
            cell.filmCoverImageView.sd_setImage(with: url)
        }
        .disposed(by: disposeBag)
        
        output.isFavoritesEmpty.drive(onNext: { [weak self] status in
            self?.isFavoritesEmpty(status: status)
        })
        .disposed(by: disposeBag)
        
        output.switchToComingSoon.drive().disposed(by: disposeBag)
        
        output.error.drive(onNext: { error in
            print(error)
        })
        .disposed(by: disposeBag)
    }
    
    private func isFavoritesEmpty(status: Bool) {
        ifFavoritesEmptyStackView.isHidden = !status
        favoritesTable.isHidden = status
    }
    
    private func addSubviews() {
        view.addSubview(favoritesTable)
        view.addSubview(ifFavoritesEmptyStackView)
        ifFavoritesEmptyStackView.addArrangedSubview(emptyTitleListLabel)
        ifFavoritesEmptyStackView.addArrangedSubview(emptySubtitleListLabel)
        ifFavoritesEmptyStackView.addArrangedSubview(switchButton)
    }
    
    private func setConstraints() {
        favoritesTable.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        ifFavoritesEmptyStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        emptyTitleListLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        emptySubtitleListLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        switchButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return FavoritesTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 256
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            favoritesTable.beginUpdates()
            favoritesTable.deleteRows(at: [indexPath], with: .fade)
            favoritesTable.endUpdates()
        }
    }
}
