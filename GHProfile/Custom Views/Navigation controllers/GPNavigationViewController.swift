//
//  GPNavigationViewController.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.08.2021.
//

import UIKit

class GPNavigationViewController: UINavigationController {
    
    init(rootViewController: UIViewController, title: String, image: UIImage) {
        super.init(rootViewController: rootViewController)
        
        tabBarItem.title = title
        tabBarItem.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
