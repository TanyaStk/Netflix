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
    
    var filmCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(filmCoverImageView)
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
