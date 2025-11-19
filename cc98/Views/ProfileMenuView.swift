//
//  ProfileMenuView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct ProfileMenuView: View {
    @ObservedObject var gamesManager: GamesManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showResetConfirmation = false
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(hex: "0a1a3b"))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "bd0e1b"), Color(hex: "ffbe00")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        }
                        .shadow(radius: 10)
                        .padding(.top, 30)
                        
                        Text("Player")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ProfileStatCard(
                                icon: "star.fill",
                                title: "Total Score",
                                value: "\(gamesManager.playerStats.totalScore)",
                                color: Color(hex: "ffbe00")
                            )
                            
                            ProfileStatCard(
                                icon: "play.circle.fill",
                                title: "Games Played",
                                value: "\(gamesManager.playerStats.gamesPlayed)",
                                color: Color(hex: "bd0e1b")
                            )
                            
                            ProfileStatCard(
                                icon: "trophy.fill",
                                title: "Best Wins",
                                value: "\(gamesManager.playerStats.totalWins)",
                                color: Color(hex: "00ff88")
                            )
                            
                            ProfileStatCard(
                                icon: "gamecontroller.fill",
                                title: "Unlocked",
                                value: "\(gamesManager.games.filter { $0.isUnlocked }.count)/\(gamesManager.games.count)",
                                color: Color(hex: "0a1a3b")
                            )
                        }
                        .padding(.horizontal)
                        
                        // Reset Button
                        Button(action: {
                            showResetConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset Progress")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "bd0e1b"))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .alert(isPresented: $showResetConfirmation) {
            Alert(
                title: Text("Reset Progress"),
                message: Text("Are you sure you want to reset all your progress? This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    gamesManager.resetProgress()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(hex: "0a1a3b"))
        .cornerRadius(16)
    }
}

// MARK: - Stats View
struct StatsView: View {
    let playerStats: PlayerStats
    let games: [MiniGame]
    @Environment(\.presentationMode) var presentationMode
    
    var topGames: [MiniGame] {
        games.filter { $0.highScore > 0 }
            .sorted { $0.highScore > $1.highScore }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "ffbe00"))
                        Text("Statistics")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .opacity(0)
                }
                .padding()
                .background(Color(hex: "0a1a3b"))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overall Stats
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Overview")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                StatsRow(title: "Total Score", value: "\(playerStats.totalScore)", icon: "star.fill")
                                StatsRow(title: "Games Played", value: "\(playerStats.gamesPlayed)", icon: "play.circle.fill")
                                StatsRow(title: "Total Wins", value: "\(playerStats.totalWins)", icon: "trophy.fill")
                            }
                            .padding()
                            .background(Color(hex: "0a1a3b"))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Top Games
                        if !topGames.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Top Scores")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    ForEach(Array(topGames.enumerated()), id: \.element.id) { index, game in
                                        HStack {
                                            Text("#\(index + 1)")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(hex: "ffbe00"))
                                                .frame(width: 40)
                                            
                                            Image(systemName: game.icon)
                                                .font(.system(size: 20))
                                                .foregroundColor(Color(hex: game.category.color))
                                                .frame(width: 30)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(game.name)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(.white)
                                                Text(game.category.rawValue)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(game.highScore)")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(hex: "ffbe00"))
                                        }
                                        .padding()
                                        .background(Color(hex: "0a1a3b"))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct StatsRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "ffbe00"))
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

