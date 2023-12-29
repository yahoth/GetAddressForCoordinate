//
//  AppleAPIViewModel.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/29/23.
//

import Foundation
import CoreLocation

class AppleAPIViewModel {
    @Published var addressName: String?

    func reverseGeocodeLocation(_ coordinate: CLLocationCoordinate2D) async throws {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemark = try await geocoder.reverseGeocodeLocation(location).first
        //간단한 주소
        let result = "\(placemark?.locality ?? String()) \(placemark?.subLocality ?? String())"

        if result.trimmingCharacters(in: .whitespaces).count > 0 {
            addressName = result
        } else {
            addressName = "lat: \(coordinate.latitude), long: \(coordinate.longitude)"
        }
    }

    func updateAddres(to coordinate: CLLocationCoordinate2D) {
        Task {
            try await reverseGeocodeLocation(coordinate)
        }
    }
}
