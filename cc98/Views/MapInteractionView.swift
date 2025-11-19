//
//  MapInteractionView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import MapKit

struct MapInteractionView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var locationService: LocationService
    @State private var showMapControls = true
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $mapViewModel.region,
                showsUserLocation: true,
                annotationItems: gameViewModel.pois) { poi in
                MapAnnotation(coordinate: poi.location) {
                    POIMarker(poi: poi) {
                        gameViewModel.selectedPOI = poi
                    }
                }
            }
            .ignoresSafeArea()
            
            // Map controls
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Center on user button
                        Button(action: {
                            if let location = locationService.userLocation {
                                mapViewModel.centerOnUser(location: location)
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color(hex: "0a1a3b").opacity(0.95))
                                .cornerRadius(12)
                        }
                        
                        // Refresh POIs button
                        Button(action: {
                            if let location = locationService.userLocation {
                                gameViewModel.loadPOIs(near: location)
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color(hex: "0a1a3b").opacity(0.95))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.trailing)
                    .padding(.bottom, 120)
                }
                
                // Bottom info panel
                if let userLocation = locationService.userLocation, showMapControls {
                    VStack(spacing: 12) {
                        HStack(spacing: 20) {
                            StatBadge(
                                icon: "map.fill",
                                value: "\(gameViewModel.pois.filter { !$0.isCaptured }.count)",
                                label: "Available"
                            )
                            
                            StatBadge(
                                icon: "checkmark.circle.fill",
                                value: "\(gameViewModel.pois.filter { $0.isCaptured }.count)",
                                label: "Captured"
                            )
                            
                            if let nearestPOI = nearestUncapturedPOI(to: userLocation) {
                                if let distance = distanceToNearest(to: userLocation, poi: nearestPOI) {
                                    StatBadge(
                                        icon: "location.fill",
                                        value: "\(Int(distance))m",
                                        label: "Nearest"
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if let nearestPOI = nearestUncapturedPOI(to: userLocation) {
                            Button(action: {
                                gameViewModel.selectedPOI = nearestPOI
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(nearestPOI.name)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        HStack(spacing: 8) {
                                            Image(systemName: challengeIcon(for: nearestPOI.challengeType))
                                                .font(.system(size: 12))
                                            Text(nearestPOI.challengeType.rawValue)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("+\(nearestPOI.points)")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(Color(hex: "ffbe00"))
                                        Text("points")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding()
                                .background(Color(hex: "0a1a3b").opacity(0.95))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 16)
                    .background(Color(hex: "02102b").opacity(0.95))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
            }
        }
        .onAppear {
            if let location = locationService.userLocation {
                mapViewModel.updateRegion(to: location)
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
    
    private func nearestUncapturedPOI(to location: CLLocationCoordinate2D) -> POI? {
        let uncaptured = gameViewModel.pois.filter { !$0.isCaptured }
        return uncaptured.min(by: { poi1, poi2 in
            let dist1 = distance(from: location, to: poi1.location)
            let dist2 = distance(from: location, to: poi2.location)
            return dist1 < dist2
        })
    }
    
    private func distanceToNearest(to location: CLLocationCoordinate2D, poi: POI) -> Double? {
        return distance(from: location, to: poi.location)
    }
    
    private func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}

struct POIMarker: View {
    let poi: POI
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(poi.isCaptured ? Color.gray.opacity(0.6) : Color(hex: "bd0e1b"))
                    .frame(width: 44, height: 44)
                
                if poi.isCaptured {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    VStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        Text("\(poi.points)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .shadow(color: poi.isCaptured ? .clear : Color(hex: "bd0e1b").opacity(0.5), radius: 8, x: 0, y: 4)
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(value)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(Color(hex: "ffbe00"))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(hex: "0a1a3b").opacity(0.8))
        .cornerRadius(10)
    }
}

// Custom corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
