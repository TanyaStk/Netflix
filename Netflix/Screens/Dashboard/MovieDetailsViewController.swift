//
//  MovieDetailsViewController.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 12.07.2022.
//

import UIKit
import SnapKit

class MovieDetailsViewController: UIViewController {
    
    private lazy var movieCoverImageView = LatestFilmView()
    
    private let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Never Have I Ever"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.imageView?.snp.makeConstraints({ make in
            make.width.height.equalToSuperview()
        })
        button.tintColor = .white
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.imageView?.snp.makeConstraints({ make in
            make.width.height.equalToSuperview()
        })
        button.tintColor = .white
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let runtimeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "clock"))
        imageView.tintColor = Asset.Colors.loginTexts.color
        return imageView
    }()
    
    private let runtimeLabel: UILabel = {
        let label = UILabel()
        label.text = "30 minutes"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let ratingIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = Asset.Colors.loginTexts.color
        return imageView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "7.8 (IMDb)"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let releaseDateHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Release date"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.text = "April 27, 2020"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let synopsisHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Synopsis"
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let synopsisDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = """
                    The complicated life of a modern-day first generation Indian American teenage girl, inspired by Mindy Kaling's own childhood.
                    """
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = Asset.Colors.loginTexts.color
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(movieCoverImageView)
        view.addSubview(movieTitleLabel)
        view.addSubview(backButton)
        view.addSubview(likeButton)
        view.addSubview(playButton)
        view.addSubview(runtimeIcon)
        view.addSubview(runtimeLabel)
        view.addSubview(ratingIcon)
        view.addSubview(ratingLabel)
        view.addSubview(releaseDateHeaderLabel)
        view.addSubview(releaseDateLabel)
        view.addSubview(synopsisHeaderLabel)
        view.addSubview(synopsisDescriptionLabel)
    }
    
    private func setConstraints() {
        movieCoverImageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        backButton.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.05)
            make.width.equalTo(backButton.snp.height)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-8)
            make.left.equalToSuperview().offset(8)
        }
        
        likeButton.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.05)
            make.width.equalTo(likeButton.snp.height)
            make.centerY.equalTo(backButton.snp.centerY)
            make.right.equalToSuperview().offset(-8)
        }
        
        playButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.05)
            make.centerY.equalTo(movieCoverImageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        movieTitleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.05)
            make.top.equalTo(playButton.snp.bottom).offset(8)
        }
        
        runtimeIcon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.05)
            make.height.equalTo(ratingIcon.snp.width)
            make.left.equalToSuperview().offset(8)
            make.top.equalTo(movieTitleLabel.snp.bottom)
        }
        
        runtimeLabel.snp.makeConstraints { make in
            make.height.equalTo(runtimeIcon.snp.height)
            make.width.equalToSuperview().multipliedBy(0.45)
            make.left.equalTo(runtimeIcon.snp.right).offset(8)
            make.centerY.equalTo(runtimeIcon.snp.centerY)
        }
        
        ratingIcon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.05)
            make.height.equalTo(ratingIcon.snp.width)
            make.left.equalTo(runtimeLabel.snp.right)
            make.centerY.equalTo(runtimeIcon.snp.centerY)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.height.equalTo(ratingIcon.snp.height)
            make.width.equalToSuperview().multipliedBy(0.45)
            make.left.equalTo(ratingIcon.snp.right).offset(8)
            make.centerY.equalTo(runtimeIcon.snp.centerY)
        }
        
        releaseDateHeaderLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(ratingIcon.snp.bottom).offset(16)
        }
        
        releaseDateLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(releaseDateHeaderLabel.snp.bottom).offset(8)
        }
        
        synopsisHeaderLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(releaseDateLabel.snp.bottom).offset(16)
        }
        
        synopsisDescriptionLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(synopsisHeaderLabel.snp.bottom).offset(8)
        }
        
    }
    
}
