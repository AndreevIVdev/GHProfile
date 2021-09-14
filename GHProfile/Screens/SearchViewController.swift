//
//  SearchViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.08.2021.
//

import UIKit

class SearchViewController: GPDataLoadingViewController {
    
    private let logoImageView = UIImageView()
    private let usernameTextField = GPTextField()
    private let callToActionButton = GPButton(backgroundColor: .darkGreen, title: "Get Profile")

    private var isUserNameEntered: Bool {
        !usernameTextField.text!.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        view.addSubViews(logoImageView, usernameTextField, callToActionButton)
        configureLogoImageView()
        configureUsernameTextField()
        configureCallToActionButton()

        createDismissKeyboardTapGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        usernameTextField.text = ""
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .darkGreen
    }
    
    private func configureLogoImageView() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = Images.ghLogo
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? 20 : 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func configureUsernameTextField() {
        usernameTextField.delegate = self

        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 48),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureCallToActionButton() {
        callToActionButton.addTarget(self, action: #selector(pushProfile), for: .touchUpInside)

        NSLayoutConstraint.activate([
            callToActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    @objc private func pushProfile() {
        guard isUserNameEntered else {
            presentGPAlertOnMainTread(title: "Empty Username", message: "Please enter a username!", buttonTitle: "Ok")
            return
        }
        usernameTextField.resignFirstResponder()
        showLoadingView()
        NetworkManager.shared.getUser(for: usernameTextField.text!) { [weak self] result in
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
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    self.usernameTextField.text = ""
                }
            }
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushProfile()
        return true
    }
}
