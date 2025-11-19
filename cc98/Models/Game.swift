//
//  Game.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import Foundation

enum GameCategory: String, CaseIterable, Codable {
    case puzzle = "Puzzle"
    case action = "Action"
    case brain = "Brain"
    case logic = "Logic"
    
    var icon: String {
        switch self {
        case .puzzle: return "puzzlepiece.fill"
        case .action: return "flame.fill"
        case .brain: return "brain.head.profile"
        case .logic: return "lightbulb.fill"
        }
    }
    
    var color: String {
        switch self {
        case .puzzle: return "bd0e1b"
        case .action: return "ffbe00"
        case .brain: return "0a1a3b"
        case .logic: return "00ff88"
        }
    }
}

struct MiniGame: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var category: GameCategory
    var icon: String
    var difficulty: GameDifficulty
    var highScore: Int
    var timesPlayed: Int
    var isUnlocked: Bool
    var unlockRequirement: Int // number of points needed
    
    init(id: UUID = UUID(), name: String, description: String, category: GameCategory, icon: String, difficulty: GameDifficulty, highScore: Int = 0, timesPlayed: Int = 0, isUnlocked: Bool = true, unlockRequirement: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.icon = icon
        self.difficulty = difficulty
        self.highScore = highScore
        self.timesPlayed = timesPlayed
        self.isUnlocked = isUnlocked
        self.unlockRequirement = unlockRequirement
    }
}

enum GameDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .easy: return "00ff88"
        case .medium: return "ffbe00"
        case .hard: return "ff6b00"
        case .expert: return "bd0e1b"
        }
    }
}

struct PlayerStats: Codable {
    var totalScore: Int
    var gamesPlayed: Int
    var totalWins: Int
    var favoriteCategory: GameCategory?
    var achievements: [String]
    
    init(totalScore: Int = 0, gamesPlayed: Int = 0, totalWins: Int = 0, favoriteCategory: GameCategory? = nil, achievements: [String] = []) {
        self.totalScore = totalScore
        self.gamesPlayed = gamesPlayed
        self.totalWins = totalWins
        self.favoriteCategory = favoriteCategory
        self.achievements = achievements
    }
    
    mutating func addScore(_ score: Int) {
        totalScore += score
    }
    
    mutating func incrementGamesPlayed() {
        gamesPlayed += 1
    }
    
    mutating func incrementWins() {
        totalWins += 1
    }
}

