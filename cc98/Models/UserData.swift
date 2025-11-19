//
//  UserData.swift
//  GeoDash
//
//  Created by IGOR on 17/11/2025.
//

import Foundation

struct UserData: Codable {
    var totalPoints: Int
    var capturedPOIs: [UUID]
    var unlockedTerritories: [String]
    var level: Int
    var username: String
    var achievements: [Achievement]
    
    init(totalPoints: Int = 0, capturedPOIs: [UUID] = [], unlockedTerritories: [String] = ["starter"], level: Int = 1, username: String = "Explorer", achievements: [Achievement] = []) {
        self.totalPoints = totalPoints
        self.capturedPOIs = capturedPOIs
        self.unlockedTerritories = unlockedTerritories
        self.level = level
        self.username = username
        self.achievements = achievements
    }
    
    mutating func capturePOI(_ poi: POI) {
        guard !capturedPOIs.contains(poi.id) else { return }
        capturedPOIs.append(poi.id)
        totalPoints += poi.points
        updateLevel()
    }
    
    mutating func unlockTerritory(_ territoryID: String) {
        if !unlockedTerritories.contains(territoryID) {
            unlockedTerritories.append(territoryID)
        }
    }
    
    private mutating func updateLevel() {
        let newLevel = (totalPoints / 100) + 1
        if newLevel > level {
            level = newLevel
        }
    }
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var isUnlocked: Bool
    
    init(id: UUID = UUID(), name: String, description: String, isUnlocked: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.isUnlocked = isUnlocked
    }
}

