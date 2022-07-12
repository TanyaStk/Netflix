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
    
    lazy var navigationButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        [self.backButton,
         self.likeButton].forEach { stack.addArrangedSubview($0) }
        return stack
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
    
    lazy var runtimeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = -60
        stack.distribution = .equalSpacing
        [self.runtimeIcon,
         self.runtimeLabel].forEach { stack.addArrangedSubview($0) }
        return stack
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
    
    lazy var ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = -50
        stack.distribution = .equalSpacing
        [self.ratingIcon,
         self.ratingLabel].forEach { stack.addArrangedSubview($0) }
        return stack
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
    
    lazy var releaseDateStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        [self.releaseDateHeaderLabel,
         self.releaseDateLabel].forEach { stack.addArrangedSubview($0) }
        return stack
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
    
    lazy var synopsisStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        [self.synopsisHeaderLabel,
         self.synopsisDescriptionLabel].forEach { stack.addArrangedSubview($0) }
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(movieCoverImageView)
        view.addSubview(movieTitleLabel)
        view.addSubview(navigationButtonsStackView)
        view.addSubview(playButton)
        view.addSubview(runtimeStackView)
        view.addSubview(ratingStackView)
        view.addSubview(releaseDateStackView)
        view.addSubview(synopsisStackView)
    }
    
    private func setConstraints() {
        movieCoverImageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        navigationButtonsStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-8)
            make.centerX.equalToSuperview()
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
        
        runtimeStackView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.02)
            make.left.equalToSuperview().offset(8)
            make.top.equalTo(movieTitleLabel.snp.bottom)
        }
        
        ratingStackView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.02)
            make.left.equalTo(runtimeStackView.snp.right).offset(8)
            make.top.equalTo(movieTitleLabel.snp.bottom)
        }
            
        releaseDateStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(ratingStackView.snp.bottom).offset(16)
        }
        
        synopsisStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(releaseDateStackView.snp.bottom).offset(16)
        }
    }
    
}
