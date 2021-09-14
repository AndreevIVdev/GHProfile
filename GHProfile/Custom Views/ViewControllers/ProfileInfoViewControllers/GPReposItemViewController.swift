//
//  GPReposItemViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import UIKit

import UIKit

protocol GPReposItemViewControllerDelegate: AnyObject {
    func didTapOnGitHubProfile(for user: User)
}

class GPReposItemViewController: GPItemInfoViewController {
    
    weak var delegate: GPReposItemViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureItems()
    }
    
    override func actionButtonTapped() {
        delegate.didTapOnGitHubProfile(for: user)
    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .repos, withCount: user.publicRepos)
        itemInfoViewTwo.set(itemInfoType: .gists, withCount: user.publicGists)
        actionButton.set(backgroundColor: .systemPurple, title: "GitHub Profile")
    }
}

