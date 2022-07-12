//
//  FavoritesViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import UIKit
import SnapKit

class FavoritesViewController: UIViewController {
    
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
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .vertical
//        stackView.isHidden = true
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setConstraints()
        
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .clear
    }
    
    private func addSubviews() {
        view.addSubview(favoritesTable)
        view.addSubview(stackView)
        stackView.addArrangedSubview(emptyTitleListLabel)
        stackView.addArrangedSubview(emptySubtitleListLabel)
        stackView.addArrangedSubview(switchButton)
    }
    
    private func setConstraints() {
        favoritesTable.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoritesTableViewCell.identifier,
            for: indexPath) as? FavoritesTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            // remove element from list at indexPath.row
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}
