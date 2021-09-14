//
//  GPError.swift
//  GHProfile
//
//  Created by Ilya Andreev on 09.09.2021.
//

import Foundation

enum GPError: String, Error {
    
    case invalidUsername = "This username creates an invalid request, please try again."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
    case unableToFavorite = "There is an error favoriting this user. Please try again."
    case alreadyInFavorites = "You already favorited this user. You must really like him!"
}
