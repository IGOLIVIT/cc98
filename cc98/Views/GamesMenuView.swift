//
//  GamesMenuView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct GamesMenuView: View {
    @StateObject private var gamesManager = GamesManager()
    @State private var selectedCategory: GameCategory? = nil
    @State private var showProfile = false
    @State private var showStats = false
    @State private var selectedGame: MiniGame?
    
    var filteredGames: [MiniGame] {
        if let category = selectedCategory {
            return gamesManager.games.filter { $0.category == category }
        }
        return gamesManager.games
    }
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack(spacing: 12) {
                    // Score
                    HStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "ffbe00"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Score")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(gamesManager.playerStats.totalScore)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "0a1a3b").opacity(0.95))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Stats button
                    Button(action: {
                        showStats = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "0a1a3b").opacity(0.95))
                            .cornerRadius(12)
                    }
                    
                    // Profile button
                    Button(action: {
                        showProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "ffbe00"))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "0a1a3b").opacity(0.95))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Hero Section
                        VStack(spacing: 8) {
                            Text("Mini Games")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(gamesManager.games.filter { $0.isUnlocked }.count) games available")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.vertical, 20)
                        
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryButton(
                                    title: "All",
                                    icon: "square.grid.2x2.fill",
                                    isSelected: selectedCategory == nil,
                                    color: Color.white
                                ) {
                                    selectedCategory = nil
                                }
                                
                                ForEach(GameCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        title: category.rawValue,
                                        icon: category.icon,
                                        isSelected: selectedCategory == category,
                                        color: Color(hex: category.color)
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Games Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredGames) { game in
                                GameCard(game: game) {
                                    if game.isUnlocked {
                                        selectedGame = game
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .sheet(item: $selectedGame) { game in
            GameDetailView(game: game, gamesManager: gamesManager)
        }
        .sheet(isPresented: $showProfile) {
            ProfileMenuView(gamesManager: gamesManager)
        }
        .sheet(isPresented: $showStats) {
            StatsView(playerStats: gamesManager.playerStats, games: gamesManager.games)
        }
        .onAppear {
            gamesManager.checkUnlocks()
        }
    }
}

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                    AnyView(color.opacity(0.8)) :
                    AnyView(Color(hex: "0a1a3b").opacity(0.5))
            )
            .cornerRadius(20)
        }
    }
}

struct GameCard: View {
    let game: MiniGame
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Game Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: game.isUnlocked ? [
                                    Color(hex: game.category.color),
                                    Color(hex: game.category.color).opacity(0.6)
                                ] : [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    if game.isUnlocked {
                        Image(systemName: game.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("\(game.unlockRequirement)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .frame(height: 120)
                
                // Game Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(game.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(game.isUnlocked ? .white : .white.opacity(0.5))
                        .lineLimit(1)
                    
                    if game.isUnlocked {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "ffbe00"))
                            Text("\(game.highScore)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "ffbe00"))
                        }
                    } else {
                        Text("Locked")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(hex: "0a1a3b").opacity(0.8))
            }
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        game.isUnlocked ? Color(hex: game.category.color).opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .disabled(!game.isUnlocked)
    }
}

