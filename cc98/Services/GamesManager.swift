//
//  GamesManager.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import Foundation
import Combine

class GamesManager: ObservableObject {
    @Published var games: [MiniGame] = []
    @Published var playerStats: PlayerStats
    
    private let gamesKey = "savedGames"
    private let statsKey = "playerStats"
    
    init() {
        self.playerStats = GamesManager.loadPlayerStats()
        self.games = GamesManager.loadGames()
        
        if games.isEmpty {
            games = GamesManager.createDefaultGames()
            saveGames()
        }
    }
    
    static func createDefaultGames() -> [MiniGame] {
        [
            // Puzzle Games
            MiniGame(
                name: "Pair Match",
                description: "Match pairs of cards to clear the board",
                category: .brain,
                icon: "square.grid.3x3.fill",
                difficulty: .easy
            ),
            MiniGame(
                name: "Number Puzzle",
                description: "Slide tiles to arrange numbers in order",
                category: .puzzle,
                icon: "square.grid.4x3.fill",
                difficulty: .medium
            ),
            MiniGame(
                name: "Color Match",
                description: "Match three or more colors in a row",
                category: .puzzle,
                icon: "paintpalette.fill",
                difficulty: .easy
            ),
            
            // Action Games
            MiniGame(
                name: "Quick Tap",
                description: "Tap targets as fast as you can",
                category: .action,
                icon: "hand.tap.fill",
                difficulty: .easy
            ),
            MiniGame(
                name: "Reaction Time",
                description: "Test your reflexes and reaction speed",
                category: .action,
                icon: "timer",
                difficulty: .medium
            ),
            MiniGame(
                name: "Dodge Master",
                description: "Avoid obstacles and survive as long as possible",
                category: .action,
                icon: "figure.run",
                difficulty: .hard,
                isUnlocked: false,
                unlockRequirement: 100
            ),
            
            // Brain Games
            MiniGame(
                name: "Simon Says",
                description: "Repeat the sequence of colors",
                category: .brain,
                icon: "square.stack.3d.up.fill",
                difficulty: .medium
            ),
            MiniGame(
                name: "Number Recall",
                description: "Remember and recall number sequences",
                category: .brain,
                icon: "number.circle.fill",
                difficulty: .hard,
                isUnlocked: false,
                unlockRequirement: 50
            ),
            
            // Logic Games
            MiniGame(
                name: "Math Challenge",
                description: "Solve math problems against the clock",
                category: .logic,
                icon: "function",
                difficulty: .medium
            ),
            MiniGame(
                name: "Pattern Master",
                description: "Complete the pattern sequence",
                category: .logic,
                icon: "circle.hexagongrid.fill",
                difficulty: .hard,
                isUnlocked: false,
                unlockRequirement: 150
            ),
            MiniGame(
                name: "Word Scramble",
                description: "Unscramble words before time runs out",
                category: .logic,
                icon: "textformat.abc",
                difficulty: .medium
            ),
            MiniGame(
                name: "Tower of Hanoi",
                description: "Move all disks to the rightmost rod",
                category: .logic,
                icon: "square.3.layers.3d.top.filled",
                difficulty: .expert,
                isUnlocked: false,
                unlockRequirement: 200
            )
        ]
    }
    
    func updateGameScore(gameId: UUID, score: Int) {
        if let index = games.firstIndex(where: { $0.id == gameId }) {
            if score > games[index].highScore {
                games[index].highScore = score
            }
            games[index].timesPlayed += 1
            playerStats.addScore(score)
            playerStats.incrementGamesPlayed()
            saveGames()
            savePlayerStats()
        }
    }
    
    func unlockGame(gameId: UUID) {
        if let index = games.firstIndex(where: { $0.id == gameId }) {
            games[index].isUnlocked = true
            saveGames()
        }
    }
    
    func checkUnlocks() {
        for (index, game) in games.enumerated() {
            if !game.isUnlocked && playerStats.totalScore >= game.unlockRequirement {
                games[index].isUnlocked = true
            }
        }
        saveGames()
    }
    
    // MARK: - Persistence
    
    private func saveGames() {
        if let encoded = try? JSONEncoder().encode(games) {
            UserDefaults.standard.set(encoded, forKey: gamesKey)
        }
    }
    
    private static func loadGames() -> [MiniGame] {
        if let data = UserDefaults.standard.data(forKey: "savedGames"),
           let games = try? JSONDecoder().decode([MiniGame].self, from: data) {
            return games
        }
        return []
    }
    
    private func savePlayerStats() {
        if let encoded = try? JSONEncoder().encode(playerStats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    private static func loadPlayerStats() -> PlayerStats {
        if let data = UserDefaults.standard.data(forKey: "playerStats"),
           let stats = try? JSONDecoder().decode(PlayerStats.self, from: data) {
            return stats
        }
        return PlayerStats()
    }
    
    func resetProgress() {
        UserDefaults.standard.removeObject(forKey: gamesKey)
        UserDefaults.standard.removeObject(forKey: statsKey)
        games = GamesManager.createDefaultGames()
        playerStats = PlayerStats()
    }
}

