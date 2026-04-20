//
//  LocationSearchService.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 20/04/26.
//

import Foundation
import Combine
import MapKit

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    private var completer: MKLocalSearchCompleter
    
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    @Published var searchQuery = "" {
        didSet {
            self.completer.queryFragment = self.searchQuery
            
            if searchQuery.isEmpty {
                searchResults.removeAll()
            }
        }
    }
    
    override init() {
            completer = MKLocalSearchCompleter()
            super.init()
            completer.delegate = self
            // Ini memastikan Apple Maps HANYA mencari NAMA KOTA (bukan mencari nama restoran/hotel)
            completer.resultTypes = .address
        }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let filterResults = completer.results.filter {
            result in !result.title.contains(",")
        }
        DispatchQueue.main.async {
            self.searchResults = filterResults
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print("Pencarian maps error: \(error.localizedDescription)")
    }
    
}

    
    
