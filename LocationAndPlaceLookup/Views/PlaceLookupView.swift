//
//  PlaceLookupView.swift
//  LocationAndPlaceLookup
//
//  Created by app-kaihatsusha on 18/01/2026.
//  Copyright © 2026 app-kaihatsusha. All rights reserved.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    
    let locationManager: LocationManager
    @State private var searchText = ""
    @State var placeVM = PlaceViewModel()
    
    @State private var searchTask: Task<Void, Never>?
    
    @State private var searchRegion = MKCoordinateRegion()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(placeVM.places) { place in
                Text(place.name)
                    .font(.title2)
                Text(place.address)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .listStyle(.plain)
            .navigationTitle("Location Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .onAppear {
            // get search region when appears
            searchRegion = locationManager.getRegionAroundCurrentLocation() ?? MKCoordinateRegion()
        }
        .onDisappear {
            // Cancel any outstanding task when view dissappears
            searchTask?.cancel()
        }
        .onChange(of: searchText) { oldValue, newValue in
            searchTask?.cancel() // stop existing tasks that are not complete
            // if search string is empty clear out list
            guard !newValue.isEmpty else {
                placeVM.places.removeAll()
                return
            }
            
            // create new task
            searchTask = Task {
                do {
                    // wait 300ms before running task, any typing before task has run cancels old task - prevents searches on every letter if typing fast - apple call limits might kick in
                    try await Task.sleep(for: .milliseconds(300))
                    // Check if task was called during sleep, if so return and wait for new tasks
                    if Task.isCancelled { return }
                    // Verify search text hasn't changed during delay
                    if searchText == newValue {
                        // perform search
                        try await placeVM.search(text: newValue, region: searchRegion)
                    }
                } catch {
                    if !Task.isCancelled {
                        print("😡 ERROR: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    PlaceLookupView(locationManager: LocationManager())
}
