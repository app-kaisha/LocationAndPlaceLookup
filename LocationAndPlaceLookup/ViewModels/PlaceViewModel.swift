//
//  PlaceViewModel.swift
//  LocationAndPlaceLookup
//
//  Created by app-kaihatsusha on 18/01/2026.
//  Copyright © 2026 app-kaihatsusha. All rights reserved.
//

import Foundation
import MapKit

@MainActor
@Observable
class PlaceViewModel {
    
    var places: [Place] = []
    
    func search(text: String, region: MKCoordinateRegion) async throws {
        // create empty search request
        let searchRequest = MKLocalSearch.Request()
        // pass search text to the request
        searchRequest.naturalLanguageQuery = text
        // Establish search region
        searchRequest.region = region
        // create search object to perform search
        let search = MKLocalSearch(request: searchRequest)
        // run search
        let response = try await search.start()
        if response.mapItems.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "‼️ No location found"])
        }
        
        self.places = response.mapItems.map(Place.init)
        // same as:
        // self.places = response.mapItems.map{ Place(mapItem: $0)}
    }
}

// .map - returns array containing results of mapping the closure over the sequences elements
// var names = ["Jon", "Kim", "Wayne", "Nas"]
// var rappers = names.map{"Lil " + $0}
// result = ["Lil Jon", "Lil Kim", "Lil Wayne", "Lil Nas"]
