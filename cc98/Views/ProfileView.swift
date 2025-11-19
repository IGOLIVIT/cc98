//
//  ProfileView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var editingUsername = false
    @State private var tempUsername = ""
    
    var onDeleteAccount: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Spacer()
                    
                    // Invisible spacer for alignment
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .opacity(0)
                }
                .padding()
                .background(Color(hex: "0a1a3b"))
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Section
                        VStack(spacing: 15) {
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
                                
                                Text(String(viewModel.userData.username.prefix(1)).uppercased())
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .shadow(radius: 10)
                            
                            if editingUsername {
                                HStack {
                                    TextField("Username", text: $tempUsername)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: 200)
                                    
                                    Button("Save") {
                                        if !tempUsername.isEmpty {
                                            viewModel.saveUsername(tempUsername)
                                            editingUsername = false
                                        }
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "bd0e1b"))
                                }
                            } else {
                                HStack {
                                    Text(viewModel.userData.username)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        tempUsername = viewModel.userData.username
                                        editingUsername = true
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color(hex: "ffbe00"))
                                    }
                                }
                            }
                            
                            // Level badge
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16))
                                Text("Level \(viewModel.userData.level)")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "0a1a3b"))
                            .cornerRadius(20)
                        }
                        .padding(.top, 30)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatCard(
                                icon: "star.fill",
                                title: "Points",
                                value: "\(viewModel.userData.totalPoints)",
                                color: Color(hex: "ffbe00")
                            )
                            
                            StatCard(
                                icon: "flag.fill",
                                title: "Captured",
                                value: "\(viewModel.userData.capturedPOIs.count)",
                                color: Color(hex: "bd0e1b")
                            )
                            
                            StatCard(
                                icon: "map.fill",
                                title: "Territories",
                                value: "\(viewModel.userData.unlockedTerritories.count)",
                                color: .blue
                            )
                            
                            StatCard(
                                icon: "trophy.fill",
                                title: "Achievements",
                                value: "\(viewModel.userData.achievements.filter { $0.isUnlocked }.count)",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                        
                        // Progress to next level
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Progress to Level \(viewModel.userData.level + 1)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(viewModel.userData.totalPoints % 100)/100")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
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
                                        .frame(width: geometry.size.width * CGFloat(viewModel.userData.totalPoints % 100) / 100.0, height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding()
                        .background(Color(hex: "0a1a3b"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Actions Section
                        VStack(spacing: 15) {
                            Button(action: {
                                viewModel.showDeleteConfirmation = true
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
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.showDeleteConfirmation) {
            Alert(
                title: Text("Reset Progress"),
                message: Text("Are you sure you want to reset all your progress? This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    onDeleteAccount()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct StatCard: View {
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(hex: "0a1a3b"))
        .cornerRadius(16)
    }
}

