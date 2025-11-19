//
//  POI.swift
//  GeoDash
//
//  Created by IGOR on 17/11/2025.
//

import Foundation
import CoreLocation

struct POI: Identifiable, Codable {
    let id: UUID
    var name: String
    var coordinate: CoordinateData
    var isCaptured: Bool
    var points: Int
    var challengeType: ChallengeType
    var territoryID: String
    
    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, isCaptured: Bool = false, points: Int, challengeType: ChallengeType, territoryID: String) {
        self.id = id
        self.name = name
        self.coordinate = CoordinateData(latitude: latitude, longitude: longitude)
        self.isCaptured = isCaptured
        self.points = points
        self.challengeType = challengeType
        self.territoryID = territoryID
    }
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

struct CoordinateData: Codable {
    var latitude: Double
    var longitude: Double
}

enum ChallengeType: String, Codable, CaseIterable {
    case simple = "Simple"
    case navigation = "Navigation"
    case puzzle = "Puzzle"
    case timed = "Timed"
    
    var description: String {
        switch self {
        case .simple:
            return "Reach the location"
        case .navigation:
            return "Navigate through waypoints"
        case .puzzle:
            return "Solve the puzzle"
        case .timed:
            return "Complete within time limit"
        }
    }
}

