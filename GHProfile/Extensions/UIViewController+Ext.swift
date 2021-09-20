//
//  UIViewController+Ext.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import UIKit
import SafariServices

extension UIViewController {
    
    func presentGPAlertOnMainTread(title: String, message:String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertViewController = GPAlertViewController(alertTitle: title, message: message, buttonTitle: buttonTitle)
            alertViewController.modalPresentationStyle = .overFullScreen
            alertViewController.modalTransitionStyle = .crossDissolve
            self.present(alertViewController, animated: true)
        }
    }
    
    func presentSafariViewController(with url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = .systemGreen
        present(safariViewController, animated: true)
    }
    
    func add(childViewController : UIViewController, to containerView: UIView) {
        addChild(childViewController)
        containerView.addSubViews(childViewController.view)
        childViewController.view.pinToEdges(of: containerView)
        childViewController.didMove(toParent: self)
    }
}
