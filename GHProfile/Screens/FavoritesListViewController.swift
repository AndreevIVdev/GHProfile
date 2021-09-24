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
    
    private var dragInitialIndexPath: IndexPath?
    private var dragCellSnapshot: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubViews(tableView, emptyStateView)
        configureViewController()
        configureEmptyStateView()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureTableView() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GPTableViewCell.self, forCellReuseIdentifier: Cells.GPTableViewCellReuseID)
        tableView.removeExcessCells()
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPressGesture)
        ))
    }
    
    private func configureEmptyStateView() {
        emptyStateView.pinToEdges(of: view)
    }
    
    private func getFavorites() {
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

extension FavoritesListViewController {
    
    @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: tableView)
        
        switch gesture.state {
        case .began:
            guard let indexPath = tableView.indexPathForRow(at: gestureLocation) else { return }
            let cell = tableView.cellForRow(at: indexPath) as! GPTableViewCell
            dragCellSnapshot = cell.getSnapshot(inputView: cell)
            guard dragCellSnapshot != nil else { return }
            dragInitialIndexPath = indexPath
            var center = cell.center
            dragCellSnapshot!.center = center
            dragCellSnapshot!.alpha = 0.0
            tableView.addSubview(dragCellSnapshot!)
            
            UIView.animate(withDuration: 0.25,
                           animations: {
                            center.y = gestureLocation.y
                            self.dragCellSnapshot?.center = center
                            self.dragCellSnapshot?.transform = (self.dragCellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
                            self.dragCellSnapshot?.alpha = 0.99
                            cell.alpha = 0.0
                           },
                           completion: { (finished) in
                            if finished {
                                cell.isHidden = true
                            }
                           })
            
        case .changed:
            guard let indexPath = tableView.indexPathForRow(at: gestureLocation) else { return }
            guard dragInitialIndexPath != nil,
                  dragCellSnapshot != nil else { return }
            
            var center = dragCellSnapshot!.center
            center.y = gestureLocation.y
            dragCellSnapshot!.center = center
            if indexPath != dragInitialIndexPath {
                // update your data model
                let favoriteToMove = favorites.remove(at: dragInitialIndexPath!.row)
                favorites.insert(favoriteToMove, at: indexPath.row)
                tableView.moveRow(at: dragInitialIndexPath!, to: indexPath)
                dragInitialIndexPath = indexPath
            }
            
        case .ended where dragInitialIndexPath != nil:
            guard let cell = tableView.cellForRow(at: dragInitialIndexPath!) else { return }
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.dragCellSnapshot?.center = cell.center
                            self.dragCellSnapshot?.transform = CGAffineTransform.identity
                            self.dragCellSnapshot?.alpha = 0.0
                            cell.alpha = 1.0
                           },
                           completion: { finished in
                            if finished {
                                self.dragInitialIndexPath = nil
                                self.dragCellSnapshot?.removeFromSuperview()
                                self.dragCellSnapshot = nil
                            }
            })
            
        default: return
        }
    }
}

extension FavoritesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.GPTableViewCellReuseID, for: indexPath) as! GPTableViewCell
        cell.id = UUID()
        cell.set(user: favorites[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoadingView()
        NetworkManager.shared.fetchUser(for: favorites[indexPath.row].login) { [weak self] result in
            guard let self = self else { return }
            
            self.dismissLoadingView()
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(ProfileViewController(user: user), animated: false)
                }
            case .failure(let error):
                self.presentGPAlertOnMainTread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
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
