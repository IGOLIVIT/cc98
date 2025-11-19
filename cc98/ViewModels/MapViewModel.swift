//
//  MapViewModel.swift
//  GeoDash
//
//  Created by IGOR on 17/11/2025.
//

import Foundation
import MapKit
import Combine
import SwiftUI

class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @Published var trackingMode: MapUserTrackingMode = .follow
    
    func updateRegion(to coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
    
    func centerOnUser(location: CLLocationCoordinate2D) {
        withAnimation {
            region.center = location
        }
    }
}

