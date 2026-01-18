//
//  ContentView.swift
//  LocationAndPlaceLookup
//
//  Created by app-kaihatsusha on 17/01/2026.
//  Copyright © 2026 app-kaihatsusha. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var locationManager = LocationManager()
    @State var selectedPlace: Place?
    
    @State private var sheetIsPresented = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(selectedPlace?.name ?? "n/a")
                    .font(.title2)
                Text(selectedPlace?.address ?? "n/a")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("\(selectedPlace?.latitude ?? 0.0), \(selectedPlace?.longitude ?? 0.0)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                sheetIsPresented.toggle()
            } label: {
                Image(systemName: "location.magnifyingglass")
                Text("Location Search")
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)

        }
        .padding()
        .task {
            // Get user location and handle authorisation use
            if let location = locationManager.location {
                selectedPlace = await Place(location: location)
            }
            
            // Setup callback to handle new locations after app launches - only handle first locationUpdate which we need, otherwise won't see in VStach after user first authorises location use
            // locationUpdated not async task, so have to add Task inside to get async
            locationManager.locationUpdated = { location in
                // callback has the niew location
                Task {
                    selectedPlace = await Place(location: location)
                }
            }
        }
        .sheet(isPresented: $sheetIsPresented) {
            PlaceLookupView(locationManager: locationManager, selectedPlace: $selectedPlace)
        }
    }
}

#Preview {
    ContentView()
}
