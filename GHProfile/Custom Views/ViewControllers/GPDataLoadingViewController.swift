//
//  GPDataLoadingViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 10.09.2021.
//

import UIKit

class GPDataLoadingViewController: UIViewController {
    
    private let containerView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    func showLoadingView() {
        view.addSubViews(containerView)
        containerView.pinToEdges(of: view)
        containerView.backgroundColor = .systemBackground
        
        UIView.animate(withDuration: 0.75) {
            self.containerView.alpha = 0.8
        }
        
        containerView.addSubViews(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.containerView.removeFromSuperview()
        }
    }
}
