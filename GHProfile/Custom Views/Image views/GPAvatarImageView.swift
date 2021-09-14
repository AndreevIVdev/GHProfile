//
//  GPAvatarImageView.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import UIKit

class GPAvatarImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func downloadImage(from urlString: String) {
        NetworkManager.shared.downloadImage(from: urlString) { [weak self] image in
            guard let self = self,
                  let image = image
            else {
                return
            }
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = Images.placeholder
        translatesAutoresizingMaskIntoConstraints = false
    }
}

