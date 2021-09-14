//
//  UIView+Ext.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import UIKit

extension UIView {
    
    func addSubViews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func pinToEdges(of superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: superView.widthAnchor),
            heightAnchor.constraint(equalTo: superView.heightAnchor),
            centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        ])
    }
}
