//
//  Follower.swift
//  GHProfile
//
//  Created by Ilya Andreev on 13.09.2021.
//

import Foundation

struct Follower: Codable, Hashable {
    
    var login: String
    var avatarUrl: String
    
    init(user: User) {
        self.login = user.login
        self.avatarUrl = user.avatarUrl
    }
}
