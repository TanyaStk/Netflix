//
//  FavoritesTableViewCell.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 11.07.2022.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    static let identifier = "FavoritesTableViewCell"

    let filmCoverImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.Assets.filmCover.image)
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(filmCoverImageView)
        setConstraints()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setConstraints() {
        filmCoverImageView.snp.makeConstraints { make in
            make.height.width.equalToSuperview().multipliedBy(0.9)
            make.center.equalToSuperview()
        }
    }
}
