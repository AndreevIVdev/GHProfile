//
//  Constants.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.08.2021.
//

import UIKit

enum Cells {
    
    static let GPTableViewCellReuseID = "GPTableViewCellReuseID"
    static let GPCollectionViewCellReuseID = "GPCollectionViewCellReuseID"
}

enum Images {
    
    static let search = UIImage(systemName: "magnifyingglass")!
    static let ghLogo = UIImage(named: "gh-logo")!
    static let placeholder = UIImage(named: "avatar-placeholder")!
    static let emptyStateLogo = UIImage(named: "empty-state-logo")!
    static let location = UIImage(systemName: "mappin.and.ellipse")!
    static let repos = UIImage(systemName: "folder")!
    static let gists = UIImage(systemName: "text.alignleft")!
    static let followers = UIImage(systemName: "heart")!
    static let following = UIImage(systemName: "person.2")!
    static let emptyStar = UIImage(systemName: "star")!
    static let filledStar = UIImage(systemName: "star.fill")!
}

enum ScreenSize {
    
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(height, width)
    static let minLength = min(height, width)
}

enum DeviceTypes {
    
    static let idiom = UIDevice.current.userInterfaceIdiom
    static let nativeScale = UIScreen.main.nativeScale
    static let scale = UIScreen.main.scale
    
    static let isiPhoneSE = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad = idiom == .pad && ScreenSize.maxLength >= 1024.0
    
    static func isIphoneXAspectRatio() -> Bool {
        isiPhoneX && isiPhoneXsMaxAndXr
    }
}
