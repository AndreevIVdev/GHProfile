//
//  User.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import Foundation

struct User: Codable, Equatable, Hashable {
    
    let login: String
    let avatarUrl: String
    var name: String?
    var location: String?
    var bio: String?
    let publicRepos: Int
    let publicGists: Int
    let htmlUrl: String
    let following: Int
    let followers: Int
    let createdAt: Date
}
