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

    func updateAddressInKorea(_ placemark: CLPlacemark) -> String {

        let postalCode = placemark.postalCode ?? String()
        let isoCountryCode = placemark.isoCountryCode ?? String()
        let country = placemark.country ?? String()
        let administrativeArea = placemark.administrativeArea ?? String()
        let locality = placemark.locality ?? String()
        let subLocality = placemark.subLocality ?? String()
        let name = placemark.name ?? String()
        let areasOfInterest = placemark.areasOfInterest ?? []
        let subAdministrativeArea = placemark.subAdministrativeArea ?? String()
        let inlandWater = placemark.inlandWater ?? String()
        let ocean = placemark.ocean ?? String()
        let thoroughfare = placemark.thoroughfare ?? String()
        let subThoroughfare = placemark.subThoroughfare ?? String()

        return addressInKorea()

        func addressInKorea() -> String {
            ///1.광역시, 특별시 등 도이름과 시이름이 같을 경우
            ///2.name이 sublocality를 포함하는 경우
            ///3.둘다인경우
            if administrativeArea == locality && name.contains(subLocality) {
                return "\(country) \(administrativeArea) \(subAdministrativeArea) \(name)"
            } else if administrativeArea == locality {
                return "\(country) \(administrativeArea) \(subAdministrativeArea) \(subLocality) \(name)"
            } else if name.contains(subLocality) {
                return "\(country) \(administrativeArea) \(subAdministrativeArea) \(locality) \(name)"
            } else {
                return "\(country) \(administrativeArea) \(subAdministrativeArea) \(locality) \(subLocality) \(name)"
            }
        }
    }
}
