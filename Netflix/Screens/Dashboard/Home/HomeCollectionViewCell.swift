//
//  HomeTableViewCell.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 31.05.2022.
//

import UIKit
import SnapKit

class HomeCollectionViewCell: UITableViewCell {
    
    static let identifier = "HomeTableViewCell"
    
    let filmCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Asset.Assets.filmCover.name)
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(filmCoverImageView)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
        
    private func setConstraints() {
        filmCoverImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
        }
    }
}

extension HomeCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .green
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
}
