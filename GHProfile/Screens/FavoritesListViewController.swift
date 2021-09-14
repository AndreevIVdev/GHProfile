//
//  FavoritesListViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 10.09.2021.
//

import UIKit

class FavoritesListViewController: GPDataLoadingViewController {
    
    private let tableView = UITableView()
    private let emptyStateView = GPEmptyStateView(message: "No favorites")
    private var favorites: [Follower] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubViews(tableView)
        configureViewController()
        configureEmptyStateView()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func configureTableView() {
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GPTableViewCell.self, forCellReuseIdentifier: Cells.GPTableViewCellReuseID)
        tableView.removeExcessCells()
    }
    
    func configureEmptyStateView() {
        view.addSubViews(emptyStateView)
        emptyStateView.pinToEdges(of: view)
    }
    
    func getFavorites() {
        PersistanceManager.retrieveFavorites { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let favorites):
                if favorites.isEmpty {
                    DispatchQueue.main.async {
                        self.view.bringSubviewToFront(self.emptyStateView)
                    }
                } else {
                    self.favorites = favorites
                    DispatchQueue.main.async {
                        self.tableView.reloadDataOnMainThread()
                        self.view.bringSubviewToFront(self.tableView)
                    }
                }
                
                break
            case .failure(let error):
                self.presentGPAlertOnMainTread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
            
        }
    }
}

extension FavoritesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.GPTableViewCellReuseID, for: indexPath) as! GPTableViewCell
        cell.set(user: favorites[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoadingView()
        NetworkManager.shared.getUser(for: favorites[indexPath.row].login) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.dismissLoadingView()
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.tabBarController?.selectedIndex = 0
                    let navigationController = self.tabBarController?.viewControllers?[0] as! GPNavigationViewController
                    navigationController.popViewController(animated: false)
                    navigationController.pushViewController(ProfileViewController(user: user), animated: false)
                }
            case .failure(let error):
                self.presentGPAlertOnMainTread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }

        PersistanceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.favorites.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            self.presentGPAlertOnMainTread(title: "Unable to remove", message: error.rawValue, buttonTitle: "Ok")
        }
    }
}
