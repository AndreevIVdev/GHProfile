//
//  FollowersListViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 13.09.2021.
//

import UIKit

class FollowersListViewController: GPDataLoadingViewController {
    
    enum Section { case main }
    
    var user: User!
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var page: Int = 1
    var hasMoreFollowers = true
    var isSearching = false
    var isLoadingMoreFollowers = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(user: User) {
        super .init(nibName: nil, bundle: nil)
        self.user = user
        self.title = user.login
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        configureDataSource()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        getFollowers(username: user.login, page: page)
    }
    
    
    func getFollowers(username: String, page: Int) {
        showLoadingView()
        isLoadingMoreFollowers = true
        
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            switch result {
            case .success(let followers):
                if followers.count < 100 { self.hasMoreFollowers = false }
                self.followers += followers
                
                DispatchQueue.main.async {
                    self.view.bringSubviewToFront(self.collectionView)
                }
                self.updateData(on: followers)
                
            case .failure(let error):
                self.presentGPAlertOnMainTread(title: "Wrong username!", message: error.rawValue, buttonTitle: "Ok")
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.dismissViewController()
                }
            }
            self.isLoadingMoreFollowers = false
        }
    }
    
    
    func configureSearchController () {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubViews(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(GPCollectionViewCell.self, forCellWithReuseIdentifier: Cells.GPCollectionViewCellReuseID)
        collectionView.delegate = self
    }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.GPCollectionViewCellReuseID, for: indexPath) as! GPCollectionViewCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @objc func dismissViewController() {
        navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
}

extension FollowersListViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: user.login, page: page)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        showLoadingView()
        NetworkManager.shared.getUser(for: follower.login) { [weak self] result in
            guard let self = self else {
                return
            }
            self.dismissLoadingView()
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(ProfileViewController(user: user), animated: true)
                }
            case .failure(let error):
                self.presentGPAlertOnMainTread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
}

extension FollowersListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            updateData(on: followers)
            isSearching = false
            return
        }
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)
    }
}

