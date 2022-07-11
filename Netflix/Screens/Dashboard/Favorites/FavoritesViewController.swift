//
//  FavoritesViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 27.05.2022.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    private let favoritesTable: UITableView = {
        let table = UITableView()
        table.register(FavoritesTableViewCell.self, forCellReuseIdentifier: FavoritesTableViewCell.identifier)
        table.rowHeight = UITableView.automaticDimension
        table.backgroundColor = .clear
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViews()
        setConstraints()
        
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .clear
    }
    
    private func addSubViews() {
        view.addSubview(favoritesTable)
    }
    
    private func setConstraints() {
        favoritesTable.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoritesTableViewCell.identifier,
            for: indexPath) as? FavoritesTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
