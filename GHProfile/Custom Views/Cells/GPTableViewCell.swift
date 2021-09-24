//
//  GPTableViewCell.swift
//  GHProfile
//
//  Created by Ilya Andreev on 13.09.2021.
//

import UIKit

class GPTableViewCell: UITableViewCell {
    
    let avatarImageView = GPAvatarImageView(frame: .zero)
    let usernameLabel = GPTitleLabel(textAlignment: .left, fontSize: 26)
    var id: UUID!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(user: Follower) {
        usernameLabel.text = user.login
        NetworkManager.shared.downloadImage(from: user.avatarUrl) { [weak self, id] image in
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
        super.prepareForReuse()
        
        avatarImageView.setDefaultImage()
    }
    
    private func configure() {
        addSubViews(avatarImageView, usernameLabel)
        
        accessoryType = .disclosureIndicator
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            usernameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func getSnapshot(inputView: UIView) -> UIView? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
        inputView.layer.render(in: currentContext)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}

