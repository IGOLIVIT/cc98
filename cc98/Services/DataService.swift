//
//  DataService.swift
//  GeoDash
//
//  Created by IGOR on 17/11/2025.
//

import Foundation
import CoreLocation

class DataService {
    static let shared = DataService()
    
    private init() {}
    
    func generatePOIs(near coordinate: CLLocationCoordinate2D, count: Int = 10) -> [POI] {
        var pois: [POI] = []
        let names = ["Ancient Tower", "Hidden Grove", "Mystery Cave", "Crystal Lake", "Golden Peak", "Shadow Valley", "Mystic Falls", "Dragon's Lair", "Phoenix Nest", "Emerald Forest", "Silver Mine", "Ruby Temple", "Sapphire Bay", "Diamond Plaza", "Amber Garden"]
        
        for i in 0..<count {
            let latOffset = Double.random(in: -0.05...0.05)
            let lonOffset = Double.random(in: -0.05...0.05)
            
            let poi = POI(
                name: names[i % names.count],
                latitude: coordinate.latitude + latOffset,
                longitude: coordinate.longitude + lonOffset,
                points: Int.random(in: 10...50),
                challengeType: ChallengeType.allCases.randomElement() ?? .simple,
                territoryID: "starter"
            )
            pois.append(poi)
        }
        
        return pois
    }
    
    func generateAdvancedPOIs(near coordinate: CLLocationCoordinate2D, territoryID: String) -> [POI] {
        var pois: [POI] = []
        let advancedNames = ["Titan's Gate", "Celestial Spire", "Void Nexus", "Storm Citadel", "Frost Pinnacle"]
        
        for (index, name) in advancedNames.enumerated() {
            let latOffset = Double.random(in: -0.08...0.08)
            let lonOffset = Double.random(in: -0.08...0.08)
            
            let poi = POI(
                name: name,
                latitude: coordinate.latitude + latOffset,
                longitude: coordinate.longitude + lonOffset,
                points: Int.random(in: 50...100),
                challengeType: [.navigation, .puzzle, .timed].randomElement() ?? .navigation,
                territoryID: territoryID
            )
            pois.append(poi)
        }
        
        return pois
    }
    
    func saveUserData(_ userData: UserData) {
        if let encoded = try? JSONEncoder().encode(userData) {
            UserDefaults.standard.set(encoded, forKey: "userData")
        }
    }
    
    func loadUserData() -> UserData? {
        if let savedData = UserDefaults.standard.data(forKey: "userData"),
           let decoded = try? JSONDecoder().decode(UserData.self, from: savedData) {
            return decoded
        }
        return nil
    }
    
    func deleteUserData() {
        UserDefaults.standard.removeObject(forKey: "userData")
    }
}

