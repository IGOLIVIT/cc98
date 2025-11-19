//
//  GameViewModel.swift
//  GeoDash
//
//  Created by IGOR on 17/11/2025.
//

import Foundation
import CoreLocation
import Combine

class GameViewModel: ObservableObject {
    @Published var pois: [POI] = []
    @Published var userData: UserData
    @Published var selectedPOI: POI?
    @Published var showChallengeSheet = false
    @Published var challengeMessage = ""
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        if let savedData = dataService.loadUserData() {
            self.userData = savedData
        } else {
            self.userData = UserData()
        }
    }
    
    func loadPOIs(near coordinate: CLLocationCoordinate2D) {
        var allPOIs = dataService.generatePOIs(near: coordinate, count: 15)
        
        // Add advanced POIs for unlocked territories
        for territory in userData.unlockedTerritories where territory != "starter" {
            let advancedPOIs = dataService.generateAdvancedPOIs(near: coordinate, territoryID: territory)
            allPOIs.append(contentsOf: advancedPOIs)
        }
        
        // Update POI capture status
        pois = allPOIs.map { poi in
            var updatedPOI = poi
            updatedPOI.isCaptured = userData.capturedPOIs.contains(poi.id)
            return updatedPOI
        }
    }
    
    func capturePOI(_ poi: POI, userLocation: CLLocationCoordinate2D?) {
        guard !poi.isCaptured else {
            challengeMessage = "Already captured!"
            showChallengeSheet = true
            return
        }
        
        // Check if user is close enough (within 50 meters)
        if let userLocation = userLocation {
            let distance = distanceBetween(userLocation, poi.location)
            if distance > 50 {
                challengeMessage = "You're too far away! Get within 50 meters."
                showChallengeSheet = true
                return
            }
        }
        
        // Simulate challenge completion
        userData.capturePOI(poi)
        
        // Update POI in list
        if let index = pois.firstIndex(where: { $0.id == poi.id }) {
            pois[index].isCaptured = true
        }
        
        challengeMessage = "🎉 Captured \(poi.name)!\n+\(poi.points) points"
        showChallengeSheet = true
        
        // Check for territory unlock
        checkTerritoryUnlock()
        
        // Save data
        dataService.saveUserData(userData)
    }
    
    private func checkTerritoryUnlock() {
        let capturedCount = userData.capturedPOIs.count
        
        if capturedCount >= 5 && !userData.unlockedTerritories.contains("bronze") {
            userData.unlockTerritory("bronze")
            challengeMessage += "\n\n🔓 Bronze Territory Unlocked!"
        } else if capturedCount >= 10 && !userData.unlockedTerritories.contains("silver") {
            userData.unlockTerritory("silver")
            challengeMessage += "\n\n🔓 Silver Territory Unlocked!"
        } else if capturedCount >= 20 && !userData.unlockedTerritories.contains("gold") {
            userData.unlockTerritory("gold")
            challengeMessage += "\n\n🔓 Gold Territory Unlocked!"
        }
    }
    
    private func distanceBetween(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return location1.distance(from: location2)
    }
    
    func resetGame() {
        dataService.deleteUserData()
        userData = UserData()
        pois = []
    }
}

