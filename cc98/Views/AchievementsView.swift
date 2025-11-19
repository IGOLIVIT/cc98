//
//  AchievementsView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct AchievementsView: View {
    let userData: UserData
    @Environment(\.presentationMode) var presentationMode
    
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
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "ffbe00"))
                        Text("Achievements")
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
                    VStack(spacing: 16) {
                        // Achievement Summary
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(userData.achievements.filter { $0.isUnlocked }.count)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(hex: "ffbe00"))
                                Text("Unlocked")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                                .frame(height: 40)
                            
                            VStack {
                                Text("\(userData.achievements.count)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Total")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding()
                        .background(Color(hex: "0a1a3b"))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Achievements List
                        if userData.achievements.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "trophy")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.3))
                                
                                Text("No achievements yet")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("Complete challenges to earn achievements")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.4))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(userData.achievements) { achievement in
                                    AchievementCard(achievement: achievement)
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

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ?
                          LinearGradient(
                            colors: [Color(hex: "ffbe00"), Color(hex: "bd0e1b")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) :
                          LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28))
                    .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.5))
                
                Text(achievement.description)
                    .font(.system(size: 13))
                    .foregroundColor(achievement.isUnlocked ? .white.opacity(0.7) : .white.opacity(0.3))
                    .lineLimit(2)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "ffbe00"))
            }
        }
        .padding()
        .background(Color(hex: "0a1a3b").opacity(achievement.isUnlocked ? 1 : 0.5))
        .cornerRadius(12)
    }
}

