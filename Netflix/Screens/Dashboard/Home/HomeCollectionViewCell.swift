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
    
    let borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(borderView)
        borderView.addSubview(filmCoverImageView)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setConstraints() {
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        filmCoverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addGlow() {
        contentView.clipsToBounds = false
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.systemOrange.cgColor
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOpacity = 0.7
    }
    
    func hideGlow() {
        contentView.layer.shadowColor = UIColor.clear.cgColor
    }
}
