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
        addGlow()
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
        filmCoverImageView.layer.shadowOffset = .zero
        filmCoverImageView.layer.shadowColor = UIColor.systemOrange.cgColor
        filmCoverImageView.layer.shadowRadius = 20
        filmCoverImageView.layer.shadowOpacity = 0.5
    }
}
