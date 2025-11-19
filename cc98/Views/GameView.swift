//
//  GameView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var locationService = LocationService()
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showHistory = false
    @State private var showTerritories = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            MapInteractionView(
                gameViewModel: gameViewModel,
                mapViewModel: mapViewModel,
                locationService: locationService
            )
            
            VStack {
                // Top navigation bar
                HStack(spacing: 12) {
                    // Level and Points
                    HStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "ffbe00"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Level \(gameViewModel.userData.level)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(gameViewModel.userData.totalPoints) pts")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "ffbe00").opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "0a1a3b").opacity(0.95))
                    .cornerRadius(12)
                    
                    // Territories button
                    Button(action: {
                        showTerritories = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 16))
                            Text("\(gameViewModel.userData.unlockedTerritories.count)")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(hex: "0a1a3b").opacity(0.95))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Achievements button
                    Button(action: {
                        showAchievements = true
                    }) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "ffbe00"))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "0a1a3b").opacity(0.95))
                            .cornerRadius(12)
                    }
                    
                    // History button
                    Button(action: {
                        showHistory = true
                    }) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "0a1a3b").opacity(0.95))
                            .cornerRadius(12)
                    }
                    
                    // Settings button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "0a1a3b").opacity(0.95))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
            }
            
            // POI Detail Sheet
            if let selectedPOI = gameViewModel.selectedPOI, !gameViewModel.showChallengeSheet {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        gameViewModel.selectedPOI = nil
                    }
                
                POIDetailView(
                    poi: selectedPOI,
                    userLocation: locationService.userLocation,
                    onCapture: {
                        gameViewModel.capturePOI(selectedPOI, userLocation: locationService.userLocation)
                    },
                    onClose: {
                        gameViewModel.selectedPOI = nil
                    }
                )
                .transition(.move(edge: .bottom))
            }
            
            // Challenge completion sheet
            if gameViewModel.showChallengeSheet {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        gameViewModel.showChallengeSheet = false
                    }
                
                VStack(spacing: 20) {
                    if gameViewModel.challengeMessage.contains("🎉") {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "ffbe00"))
                    } else if gameViewModel.challengeMessage.contains("🔓") {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "ffbe00"))
                    } else {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "bd0e1b"))
                    }
                    
                    Text(gameViewModel.challengeMessage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        gameViewModel.showChallengeSheet = false
                        gameViewModel.selectedPOI = nil
                    }) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "bd0e1b"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 30)
                .background(Color(hex: "0a1a3b"))
                .cornerRadius(20)
                .padding(.horizontal, 40)
            }
        }
        .sheet(isPresented: $showSettings) {
            ProfileView(
                viewModel: SettingsViewModel(userData: gameViewModel.userData),
                onDeleteAccount: {
                    gameViewModel.resetGame()
                    showSettings = false
                }
            )
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView(userData: gameViewModel.userData)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(userData: gameViewModel.userData, allPOIs: gameViewModel.pois)
        }
        .sheet(isPresented: $showTerritories) {
            TerritoriesView(userData: gameViewModel.userData)
        }
        .onAppear {
            locationService.requestLocationPermission()
        }
        .onReceive(locationService.$userLocation) { newLocation in
            if let location = newLocation {
                mapViewModel.updateRegion(to: location)
                gameViewModel.loadPOIs(near: location)
            }
        }
    }
}
