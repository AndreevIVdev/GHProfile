//
//  GPItemInfoView.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import UIKit

enum ItemInfoType {
    case repos, gists, followers, following
}

class GPItemInfoView: UIView {
    
    let symbolImageView = UIImageView()
    let titleLabel = GPTitleLabel(textAlignment: .left, fontSize: 14)
    let countLabel = GPTitleLabel(textAlignment: .center, fontSize: 14)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(itemInfoType: ItemInfoType, withCount count: Int) {
        switch itemInfoType {
        case .repos:
            symbolImageView.image = Images.repos
            titleLabel.text = "Public repos"
        case .gists:
            symbolImageView.image = Images.gists
            titleLabel.text = "Public Gists"
        case .followers:
            symbolImageView.image = Images.followers
            titleLabel.text = "Followers"
        case .following:
            symbolImageView.image = Images.following
            titleLabel.text = "Following"
        }
        countLabel.text = String(count)
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubViews(symbolImageView, titleLabel, countLabel)
        
        symbolImageView.contentMode = .scaleAspectFill
        symbolImageView.tintColor = .label
        
        NSLayoutConstraint.activate([
            symbolImageView.topAnchor.constraint(equalTo: self.topAnchor),
            symbolImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            symbolImageView.widthAnchor.constraint(equalToConstant: 20),
            symbolImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: symbolImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            countLabel.topAnchor.constraint(equalTo: symbolImageView.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            countLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            countLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
