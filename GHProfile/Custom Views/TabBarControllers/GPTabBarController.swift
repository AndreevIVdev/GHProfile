//
//  GPTabBarController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.08.2021.
//

import UIKit

class GPTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .darkGreen
        UITabBar.appearance().barTintColor = .systemBackground
        
        let searchViewController = SearchViewController()
        let favoritesViewController = FavoritesListViewController()
        
        let searchNavigationController = GPNavigationViewController(rootViewController: searchViewController, title: "Search", image: Images.search)
        let favoritesNavigationController = GPNavigationViewController(rootViewController: favoritesViewController, title: "Favorites", image: Images.emptyStar)
        viewControllers = [searchNavigationController, favoritesNavigationController]
    }
}
