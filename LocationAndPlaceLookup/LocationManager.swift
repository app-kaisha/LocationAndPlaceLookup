//
//  LocationManager.swift
//  LocationAndPlaceLookup
//
//  Created by app-kaihatsusha on 17/01/2026.
//  Copyright © 2026 app-kaihatsusha. All rights reserved.
//

import Foundation
import MapKit

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    // *******************************CRITICAL*******************************************
    // Always add info.plist message for Privacy - Location When In Use Usage Description
    
    var location: CLLocation?
    private let locationManager = CLLocationManager()
    var authorisationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // get a region around the current location with specified radius in metres (10Km defualt)
    func getRegionAroundCurrentLocation(radiusInMetres: CLLocationDistance = 10000) -> MKCoordinateRegion? {
        guard let location = location else { return nil }
        return MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusInMetres,
            longitudinalMeters: radiusInMetres
        )
    }
}

// Delegate Methods which Apple will call
extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
        
        // uncomment line below if only want to get location once
        // manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        errorMessage = error.localizedDescription
        print("😡🗺️ ERROR LocationManager: \(errorMessage ?? "n/a")")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorisationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("LocationManager authorisation granted!")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("LocationManager authorisation denied!")
            errorMessage = "😡📍 LocationManager access denied!"
            manager.stopUpdatingLocation()
        case .notDetermined:
            print("LocationManager authorisation not determined!")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            print("Possible new enum created for CLLocationManager.authorizationStatus!s")
            manager.requestWhenInUseAuthorization()
        }
    }
}
