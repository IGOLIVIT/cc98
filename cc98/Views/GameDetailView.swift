//
//  GameDetailView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct GameDetailView: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showGame = false
    
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
                        // Game Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: game.category.color),
                                            Color(hex: game.category.color).opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: game.icon)
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color(hex: game.category.color).opacity(0.5), radius: 20, x: 0, y: 10)
                        .padding(.top, 30)
                        
                        // Game Title
                        VStack(spacing: 8) {
                            Text(game.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 6) {
                                Image(systemName: game.category.icon)
                                    .font(.system(size: 14))
                                Text(game.category.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color(hex: game.category.color))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color(hex: game.category.color).opacity(0.2))
                            .cornerRadius(20)
                        }
                        
                        // Description
                        Text(game.description)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Stats
                        HStack(spacing: 16) {
                            StatBox(
                                icon: "star.fill",
                                title: "Best",
                                value: "\(game.highScore)",
                                color: Color(hex: "ffbe00")
                            )
                            
                            StatBox(
                                icon: "play.fill",
                                title: "Played",
                                value: "\(game.timesPlayed)",
                                color: Color(hex: "bd0e1b")
                            )
                            
                            StatBox(
                                icon: "gauge.high",
                                title: "Level",
                                value: game.difficulty.rawValue,
                                color: Color(hex: game.difficulty.color)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Play Button
                        Button(action: {
                            showGame = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20))
                                Text("Play Now")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "bd0e1b"), Color(hex: "ffbe00")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "bd0e1b").opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showGame) {
            GamePlayView(game: game, gamesManager: gamesManager)
        }
    }
}

struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(hex: "0a1a3b"))
        .cornerRadius(12)
    }
}

