//
//  Place.swift
//  LocationAndPlaceLookup
//
//  Created by app-kaihatsusha on 18/01/2026.
//  Copyright © 2026 app-kaihatsusha. All rights reserved.
//

import Foundation
import MapKit
import Contacts

struct Place : Identifiable {
    let id = UUID().uuidString
    
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    // initialise a place from coordinates
    init(location: CLLocation) async {
        // reverse geo coding
        let geocoder = CLGeocoder()
        do {
            guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
                self.init(mapItem: MKMapItem())
                return
            }
            let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
            self.init(mapItem: mapItem)
        } catch {
            print("😡🌍 GEOCODING ERROR: \(error.localizedDescription)")
            self.init(mapItem: MKMapItem())
        }
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var latitude: Double {
        self.mapItem.placemark.coordinate.latitude
    }
    
    var longitude: Double {
        self.mapItem.placemark.coordinate.longitude
    }
    
    var address: String {
        let postalAddress = mapItem.placemark.postalAddress ?? CNPostalAddress()
        // get string version with muliple lines
        var address = CNPostalAddressFormatter().string(from: postalAddress)
        // make a single line
        address = address.replacingOccurrences(of: "\n", with: ", ")
        
        return address
    }
    
    var altAddress: String {
        let placemark = self.mapItem.placemark
        var cityAndState = ""
        var address = ""
        
        cityAndState = placemark.locality ?? ""
        if let state = placemark.administrativeArea {
            // Show either state or city,state
            cityAndState = cityAndState.isEmpty ? state : "\(cityAndState) , \(state)"
        }
        
        address = placemark.subThoroughfare ?? "" // address
        if let street = placemark.thoroughfare {
            // Just street unless there is a steet # then add space + street
            address = address.isEmpty ? street : "\(address), \(street)"
        }
        
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
            address = cityAndState
        } else {
            address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
        }
        
        return address
    }
    
}
