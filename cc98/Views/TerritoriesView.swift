//
//  TerritoriesView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct TerritoriesView: View {
    let userData: UserData
    @Environment(\.presentationMode) var presentationMode
    
    var territories: [Territory] {
        [
            Territory(
                id: "starter",
                name: "Starter Zone",
                icon: "map.fill",
                color: Color.blue,
                requirement: "Start playing",
                unlockAt: 0,
                isUnlocked: true
            ),
            Territory(
                id: "bronze",
                name: "Bronze Territory",
                icon: "shield.fill",
                color: Color.orange,
                requirement: "Capture 5 POIs",
                unlockAt: 5,
                isUnlocked: userData.unlockedTerritories.contains("bronze")
            ),
            Territory(
                id: "silver",
                name: "Silver Territory",
                icon: "shield.lefthalf.filled",
                color: Color.gray,
                requirement: "Capture 10 POIs",
                unlockAt: 10,
                isUnlocked: userData.unlockedTerritories.contains("silver")
            ),
            Territory(
                id: "gold",
                name: "Gold Territory",
                icon: "crown.fill",
                color: Color(hex: "ffbe00"),
                requirement: "Capture 20 POIs",
                unlockAt: 20,
                isUnlocked: userData.unlockedTerritories.contains("gold")
            )
        ]
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
                        Image(systemName: "map.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "ffbe00"))
                        Text("Territories")
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
                        // Progress Summary
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ForEach(territories) { territory in
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(territory.isUnlocked ? territory.color : Color.white.opacity(0.2))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: territory.isUnlocked ? territory.icon : "lock.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text(territory.name.components(separatedBy: " ").first ?? "")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(territory.isUnlocked ? .white : .white.opacity(0.4))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            
                            // Progress bar
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Unlocked Territories")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(userData.unlockedTerritories.count)/\(territories.count)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(hex: "ffbe00"))
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(height: 8)
                                        
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "bd0e1b"), Color(hex: "ffbe00")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(
                                                width: geometry.size.width * CGFloat(userData.unlockedTerritories.count) / CGFloat(territories.count),
                                                height: 8
                                            )
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                        .padding()
                        .background(Color(hex: "0a1a3b"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Territories List
                        LazyVStack(spacing: 12) {
                            ForEach(territories) { territory in
                                TerritoryCard(
                                    territory: territory,
                                    currentCaptured: userData.capturedPOIs.count
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct Territory: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let requirement: String
    let unlockAt: Int
    let isUnlocked: Bool
}

struct TerritoryCard: View {
    let territory: Territory
    let currentCaptured: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(territory.isUnlocked ? 
                          territory.color :
                          Color.white.opacity(0.1)
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: territory.isUnlocked ? territory.icon : "lock.fill")
                    .font(.system(size: 32))
                    .foregroundColor(territory.isUnlocked ? .white : .white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(territory.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(territory.isUnlocked ? .white : .white.opacity(0.5))
                
                Text(territory.requirement)
                    .font(.system(size: 14))
                    .foregroundColor(territory.isUnlocked ? .white.opacity(0.7) : .white.opacity(0.4))
                
                if !territory.isUnlocked && territory.unlockAt > 0 {
                    HStack(spacing: 6) {
                        Text("\(currentCaptured)/\(territory.unlockAt)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "ffbe00"))
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(Color(hex: "ffbe00"))
                                    .frame(
                                        width: min(geometry.size.width * CGFloat(currentCaptured) / CGFloat(territory.unlockAt), geometry.size.width),
                                        height: 4
                                    )
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
            
            Spacer()
            
            if territory.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "ffbe00"))
            }
        }
        .padding()
        .background(Color(hex: "0a1a3b").opacity(territory.isUnlocked ? 1 : 0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(territory.isUnlocked ? territory.color.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

