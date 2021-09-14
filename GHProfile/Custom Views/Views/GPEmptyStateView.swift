//
//  GPEmptyStateView.swift
//  GHProfile
//
//  Created by Ilya Andreev on 10.09.2021.
//

import UIKit

class GPEmptyStateView: UIView {
    
    let messageLabel = GPTitleLabel(textAlignment: .center, fontSize: 28)
    let logoImageView = UIImageView()
    
    init(message: String) {
        super.init(frame: .zero)
        configure()
        configureLogoImageView()
        configureMessageLabel()
        messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubViews(logoImageView, messageLabel)
    }
    
    private func configureLogoImageView() {
        logoImageView.image = Images.emptyStateLogo
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            logoImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            logoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 200),
            logoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? 80 : 40)
        ])
    }
    
    private func configureMessageLabel() {
        messageLabel.numberOfLines = 3
        messageLabel.textColor = .secondaryLabel
        
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? -80 : -150),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            messageLabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

