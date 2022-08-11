//
//  UpcomingMoviesTableViewCell.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 11.07.2022.
//

import UIKit
import SnapKit

class MoviesCollectionViewCell: UICollectionViewCell {

    static let identifier = "MoviesCollectionViewCell"
    
    let filmCoverImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(filmCoverImageView)
        filmCoverImageView.clipsToBounds = true
        filmCoverImageView.contentMode = .scaleAspectFill
        
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
        contentView.clipsToBounds = false
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.systemOrange.cgColor
        contentView.layer.shadowRadius = 16.0
        contentView.layer.shadowOpacity = 0.8
    }
    
    func hideGlow() {
        contentView.layer.shadowColor = UIColor.clear.cgColor
    }
}
