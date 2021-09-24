//
//  GPCollectionViewCell.swift
//  GHProfile
//
//  Created by Ilya Andreev on 13.09.2021.
//

import UIKit

class GPCollectionViewCell: UICollectionViewCell {
    
    let avatarImageView = GPAvatarImageView(frame: .zero)
    let usernameLabel = GPTitleLabel(textAlignment: .center, fontSize: 16)
    var id: UUID!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(follower: Follower) {
        usernameLabel.text = follower.login
        NetworkManager.shared.fetchImage(from: follower.avatarUrl) { [weak self, id] image in
            guard let self = self,
                  let image = image,
                  self.id == id
            else { return }
            DispatchQueue.main.async {
                self.avatarImageView.image = image
            }
        }
    }
    
    override func prepareForReuse() {
        avatarImageView.setDefaultImage()
    }
    
    private func configure() {
        contentView.addSubViews(avatarImageView, usernameLabel)
        
        let padding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            usernameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
