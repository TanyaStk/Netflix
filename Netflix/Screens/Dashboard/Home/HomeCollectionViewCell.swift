//
//  HomeTableViewCell.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 31.05.2022.
//

import UIKit
import SnapKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeTableViewCell"
    
    let filmCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Asset.Assets.filmCover.name)
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(filmCoverImageView)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setConstraints() {
        filmCoverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
