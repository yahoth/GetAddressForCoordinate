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
        //let result = "\(placemark?.locality ?? "") \(placemark?.subLocality ?? "")"

        //외국 주소
        /// "1600 Pennsylvania Ave NW, Washington, DC, 20500"
        /// subThoroughfare thoroughfare, locality, administrativeArea, postalCode, country
        let result = "\(placemark?.subThoroughfare ?? String()) \(placemark?.thoroughfare ?? String()), \(placemark?.locality ?? String()), \(placemark?.administrativeArea ?? String()), \(placemark?.postalCode ?? String()), \(placemark?.country ?? String())"
        addressName = result
    }

    func updateAddres(to coordinate: CLLocationCoordinate2D) {
        Task {
            try await reverseGeocodeLocation(coordinate)
        }
    }
}
