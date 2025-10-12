//
//  FavoritesManager.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import Foundation
// MARK: - UserDefaults Keys
private enum UserDefaultsKeys {
    static let favoriteMonsters = "favoriteMonsters"
    static let favoriteSpells = "favoriteSpells"
}
// MARK: - FavoritesManager
final class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Monsters
    func addMonsterToFavorites(_ monsterName: String) {
        var favorites = getFavoriteMonsters()
        if !favorites.contains(monsterName) {
            favorites.append(monsterName)
            saveFavoriteMonsters(favorites)
        }
    }
    
    func removeMonsterFromFavorites(_ monsterName: String) {
        var favorites = getFavoriteMonsters()
        favorites.removeAll { $0 == monsterName }
        saveFavoriteMonsters(favorites)
    }
    
    func isMonsterFavorite(_ monsterName: String) -> Bool {
        return getFavoriteMonsters().contains(monsterName)
    }
    
    func getFavoriteMonsters() -> [String] {
        return userDefaults.stringArray(forKey: UserDefaultsKeys.favoriteMonsters) ?? []
    }
    
    private func saveFavoriteMonsters(_ monsters: [String]) {
        userDefaults.set(monsters, forKey: UserDefaultsKeys.favoriteMonsters)
    }
    
    // MARK: - Spells
    func addSpellToFavorites(_ spellName: String) {
        var favorites = getFavoriteSpells()
        if !favorites.contains(spellName) {
            favorites.append(spellName)
            saveFavoriteSpells(favorites)
        }
    }
    
    func removeSpellFromFavorites(_ spellName: String) {
        var favorites = getFavoriteSpells()
        favorites.removeAll { $0 == spellName }
        saveFavoriteSpells(favorites)
    }
    
    func isSpellFavorite(_ spellName: String) -> Bool {
        return getFavoriteSpells().contains(spellName)
    }
    
    func getFavoriteSpells() -> [String] {
        return userDefaults.stringArray(forKey: UserDefaultsKeys.favoriteSpells) ?? []
    }
    
    private func saveFavoriteSpells(_ spells: [String]) {
        userDefaults.set(spells, forKey: UserDefaultsKeys.favoriteSpells)
    }
}
