//
//  FollowersListViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 13.09.2021.
//

import UIKit



class FollowersListViewController: GPDataLoadingViewController {
    
    enum Section: Hashable { case main }
    
    private var user: User!
    private var followers: [Follower] = []
    private var filteredFollowers: [Follower] = []
    private var page: Int = 1
    private var hasMoreFollowers = true
    private var isSearching = false
    private var isLoadingMoreFollowers = false
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
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
        getFollowers(username: user.login, page: page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func getFollowers(username: String, page: Int) {
        showLoadingView()
        isLoadingMoreFollowers = true
        
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            switch result {
            case .success(let followers):
                if followers.count < 100 {
                    self.hasMoreFollowers = false
                }
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
    
    private func configureSearchController () {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubViews(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(GPCollectionViewCell.self, forCellWithReuseIdentifier: Cells.GPCollectionViewCellReuseID)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.GPCollectionViewCellReuseID, for: indexPath) as! GPCollectionViewCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    private func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @objc private func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}

extension FollowersListViewController: UIScrollViewDelegate {
    
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
}
    
extension FollowersListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let follower = dataSource.itemIdentifier(for: indexPath) else { return }
        showLoadingView()
        NetworkManager.shared.getUser(for: follower.login) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
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

