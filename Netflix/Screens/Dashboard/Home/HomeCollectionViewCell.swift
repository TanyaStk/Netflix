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
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(filmCoverImageView)
        backgroundColor = .clear
        contentView.backgroundColor = .black
        contentView.layer.cornerRadius = 8
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
    
    func addGlow() {
        layer.masksToBounds = false
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.systemOrange.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 8.0
    }
    
    func hideGlow() {
        layer.shadowOpacity = 0
    }
}
