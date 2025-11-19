//
//  POIDetailView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import CoreLocation

struct POIDetailView: View {
    let poi: POI
    let userLocation: CLLocationCoordinate2D?
    let onCapture: () -> Void
    let onClose: () -> Void
    
    @State private var distance: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with close button
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding()
            .padding(.top, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // POI Icon and Name
                    HStack {
                        ZStack {
                            Circle()
                                .fill(poi.isCaptured ? Color.gray : Color(hex: "bd0e1b"))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: poi.isCaptured ? "checkmark" : "star.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(poi.name)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 6) {
                                Image(systemName: territoryIcon(for: poi.territoryID))
                                    .font(.system(size: 14))
                                Text(territoryName(for: poi.territoryID))
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color(hex: "ffbe00"))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info Cards
                    VStack(spacing: 12) {
                        InfoCard(
                            icon: "star.fill",
                            title: "Points",
                            value: "\(poi.points)",
                            color: Color(hex: "ffbe00")
                        )
                        
                        InfoCard(
                            icon: challengeIcon(for: poi.challengeType),
                            title: "Challenge",
                            value: poi.challengeType.rawValue,
                            color: Color(hex: "bd0e1b")
                        )
                        
                        InfoCard(
                            icon: "location.fill",
                            title: "Distance",
                            value: distance > 1000 ? "\(String(format: "%.1f", distance/1000))km" : "\(Int(distance))m",
                            color: distance <= 50 ? .green : .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Challenge Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Challenge Details")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(poi.challengeType.description)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                        
                        if !poi.isCaptured {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14))
                                Text("Get within 50 meters to capture")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(Color(hex: "ffbe00"))
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color(hex: "0a1a3b").opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Status badge
                    if poi.isCaptured {
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Already Captured")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(25)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // Capture Button
                    if !poi.isCaptured {
                        Button(action: onCapture) {
                            HStack {
                                Image(systemName: distance <= 50 ? "checkmark.circle.fill" : "lock.fill")
                                    .font(.system(size: 20))
                                Text(distance <= 50 ? "Capture POI" : "Too Far Away")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(distance <= 50 ? Color(hex: "bd0e1b") : Color.gray)
                            .cornerRadius(16)
                        }
                        .disabled(distance > 50)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color(hex: "02102b"))
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
        .onAppear {
            if let userLoc = userLocation {
                let userCLLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
                let poiLoc = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
                distance = userCLLoc.distance(from: poiLoc)
            }
        }
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
    
    private func territoryIcon(for id: String) -> String {
        switch id {
        case "starter":
            return "map"
        case "bronze":
            return "shield.fill"
        case "silver":
            return "shield.lefthalf.filled"
        case "gold":
            return "crown.fill"
        default:
            return "map"
        }
    }
    
    private func territoryName(for id: String) -> String {
        switch id {
        case "starter":
            return "Starter Zone"
        case "bronze":
            return "Bronze Territory"
        case "silver":
            return "Silver Territory"
        case "gold":
            return "Gold Territory"
        default:
            return "Unknown"
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "0a1a3b").opacity(0.8))
        .cornerRadius(12)
    }
}

