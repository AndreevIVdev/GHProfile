//
//  ProfileViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let itemViewOne = UIView()
    private let itemViewTwo = UIView()
    private let dateLabel = GPBodyLabel(textAlignment: .center)
    private var user: User!
    private var isInFavorites: Bool?
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureScrollView()
        layoutUI()
        configureUIElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
        configureFavoriteMethod()
        setRightBarButtonItem()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .checkmark, style: .plain, target: self, action: #selector(addButtonTapped))
    }
    
    private func configureScrollView() {
        view.addSubViews(scrollView)
        scrollView.pinToEdges(of: view)
        
        scrollView.addSubViews(contentView)
        contentView.pinToEdges(of: scrollView)
    }
    
    private func layoutUI() {
        let padding: CGFloat = 20

        let itemViews = [headerView, itemViewOne, itemViewTwo, dateLabel]
        for itemView in itemViews {
            contentView.addSubViews(itemView)
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
            ])
        }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),

            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: 140),

            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: 140),

            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUIElements() {
        let repoItemViewController = GPReposItemViewController(user: user)
        repoItemViewController.delegate = self
        let followersItemViewController = GPFollowersItemViewController(user: user)
        followersItemViewController.delegate = self
        add(childViewController: GPUserInfoHeaderViewController(user: user), to: headerView)
        add(childViewController: repoItemViewController, to: itemViewOne)
        add(childViewController: followersItemViewController, to: itemViewTwo)
        dateLabel.text = "GitHub since " + user.createdAt.convertToMonthYearFormat()
        configureFavoriteMethod()
        setRightBarButtonItem()
    }
    
    private func configureFavoriteMethod() {
        PersistanceManager.isInFavorites(login: user.login) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let isInFavorites):
                self.isInFavorites = isInFavorites
                
            case .failure(let error):
                self.presentGPAlertOnMainTread(title: "Database error", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    private func setRightBarButtonItem() {
        guard let isInFavorites = isInFavorites else {
            navigationItem.rightBarButtonItem?.image = . checkmark
            return
        }
        navigationItem.rightBarButtonItem?.image = isInFavorites ? Images.filledStar : Images.emptyStar
    }
    
    @objc private func addButtonTapped() {
        defer {
            setRightBarButtonItem()
        }
        
        guard let isInFavorites = isInFavorites else { return }
        
        PersistanceManager.updateWith(favorite: Follower(user: user), actionType: isInFavorites ? .remove : .add) {[weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.isInFavorites!.toggle()
                return
            }
            self.presentGPAlertOnMainTread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            self.isInFavorites = nil
        }
    }
}

extension ProfileViewController: GPReposItemViewControllerDelegate {

    func didTapOnGitHubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGPAlertOnMainTread(title: "Invalid URL", message: "The url attached to this user is invalid!", buttonTitle: "Ok")
            return
        }
        presentSafariViewController(with: url)
    }
}

extension ProfileViewController: GPFollowersItemViewControllerDelegate {

    func didTapGitFollowers(for user: User) {
        guard user.followers != 0 else {
            presentGPAlertOnMainTread(title: "No followers", message: "This user has no followers!", buttonTitle: "Ok")
            return
        }
        navigationController?.pushViewController(FollowersListViewController(user: user), animated: true)
    }
}
