//
//  LatestFilmView.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 02.06.2022.
//

import UIKit

class HeadMovieCoverView: UIView {
    
    var filmCoverImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(filmCoverImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        filmCoverImageView.frame = bounds
        filmCoverImageView.clipsToBounds = true
        filmCoverImageView.contentMode = .scaleAspectFill
        addGradient()
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        layer.addSublayer(gradientLayer)
    }
    
}
