//
//  HistoryView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct HistoryView: View {
    let userData: UserData
    let allPOIs: [POI]
    @Environment(\.presentationMode) var presentationMode
    
    var capturedPOIs: [POI] {
        allPOIs.filter { userData.capturedPOIs.contains($0.id) }
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
                        Image(systemName: "clock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "ffbe00"))
                        Text("History")
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
                        // Summary Cards
                        HStack(spacing: 12) {
                            SummaryCard(
                                icon: "flag.checkered",
                                title: "Total Captured",
                                value: "\(capturedPOIs.count)"
                            )
                            
                            SummaryCard(
                                icon: "star.fill",
                                title: "Total Points",
                                value: "\(userData.totalPoints)"
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Statistics
                        VStack(spacing: 12) {
                            StatisticRow(
                                icon: "target",
                                title: "Simple Challenges",
                                value: capturedPOIs.filter { $0.challengeType == .simple }.count
                            )
                            
                            StatisticRow(
                                icon: "arrow.triangle.turn.up.right.diamond",
                                title: "Navigation Challenges",
                                value: capturedPOIs.filter { $0.challengeType == .navigation }.count
                            )
                            
                            StatisticRow(
                                icon: "puzzlepiece",
                                title: "Puzzle Challenges",
                                value: capturedPOIs.filter { $0.challengeType == .puzzle }.count
                            )
                            
                            StatisticRow(
                                icon: "timer",
                                title: "Timed Challenges",
                                value: capturedPOIs.filter { $0.challengeType == .timed }.count
                            )
                        }
                        .padding()
                        .background(Color(hex: "0a1a3b"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Recent Captures
                        if !capturedPOIs.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Captures")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 10) {
                                    ForEach(capturedPOIs.reversed().prefix(20)) { poi in
                                        HistoryCard(poi: poi)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "clock")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.3))
                                
                                Text("No captures yet")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("Start exploring to build your history")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "ffbe00"))
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(hex: "0a1a3b"))
        .cornerRadius(12)
    }
}

struct StatisticRow: View {
    let icon: String
    let title: String
    let value: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "ffbe00"))
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct HistoryCard: View {
    let poi: POI
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "bd0e1b"))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(poi.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Image(systemName: challengeIcon(for: poi.challengeType))
                        .font(.system(size: 11))
                    Text(poi.challengeType.rawValue)
                        .font(.system(size: 12))
                }
                .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("+\(poi.points)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "ffbe00"))
        }
        .padding()
        .background(Color(hex: "0a1a3b"))
        .cornerRadius(10)
    }
    
    private func challengeIcon(for type: ChallengeType) -> String {
        switch type {
        case .simple:
            return "target"
        case .navigation:
            return "arrow.triangle.turn.up.right.diamond"
        case .puzzle:
            return "puzzlepiece"
        case .timed:
            return "timer"
        }
    }
}

