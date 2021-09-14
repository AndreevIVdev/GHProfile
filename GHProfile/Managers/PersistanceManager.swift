//
//  PersistanceManager.swift
//  GHProfile
//
//  Created by Ilya Andreev on 10.09.2021.
//

import Foundation

enum PersistenceActionType {
    
    case add, remove
}

enum PersistanceManager {
    
    private enum Keys {
        
        static let favorites = "favorites"
    }

    private static let defaults = UserDefaults.standard
    
    static func updateWith(favorite: Follower, actionType: PersistenceActionType, completed: @escaping (GPError?) -> Void) {
        retrieveFavorites { result in
            switch result {
            case .success(var favorites):
                switch actionType {
                case .add:
                    guard !favorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    favorites.append(favorite)
                    
                case .remove:
                    favorites.removeAll { $0.login == favorite.login }
                }
                completed(save(favorites: favorites))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    static func retrieveFavorites(completed: @escaping (Result<[Follower], GPError>) -> Void) {
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let favorites = try JSONDecoder().decode([Follower].self, from: favoritesData)
            completed(.success(favorites))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
    
    static func isInFavorites(login: String, completed: @escaping (Result<Bool, GPError>) -> Void) {
        retrieveFavorites { result in
            switch result {
            case .success(let favorites):
                for user in favorites {
                    if user.login == login {
                        completed(.success(true))
                        return
                    }
                }
                completed(.success(false))
                
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    private static func save(favorites: [Follower]) -> GPError? {
        do {
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.setValue(encodedFavorites, forKey: Keys.favorites)
        } catch {
            return .unableToFavorite
        }
        return nil
    }
}

