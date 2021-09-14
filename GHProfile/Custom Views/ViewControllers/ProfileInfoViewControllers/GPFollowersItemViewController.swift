//
//  GPFollowersItemViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import UIKit

protocol GPFollowersItemViewControllerDelegate: AnyObject {
    func didTapGitFollowers(for user: User)
}

class GPFollowersItemViewController: GPItemInfoViewController {
    
    weak var delegate: GPFollowersItemViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureItems()
    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewTwo.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(backgroundColor: .systemGreen, title: "Get Followers")
    }
    
    override func actionButtonTapped() {
        delegate.didTapGitFollowers(for: user)
    }
}
