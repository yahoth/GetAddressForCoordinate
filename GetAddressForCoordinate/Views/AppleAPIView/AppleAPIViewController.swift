//
//  AppleAPIViewController.swift
//  MapPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/22.
//

import UIKit
import MapKit
import CoreLocation
import Combine

import SnapKit

class AppleAPIViewController: BaseViewController {
    var vm: AppleAPIViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = AppleAPIViewModel()
        bind()
    }

    func bind() {
        vm.$addressName
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { address in
                self.addressLabel.text = address
            }.store(in: &subscriptions)
    }



    override func coordinateChanged(to coordinate: CLLocationCoordinate2D) {
        vm.updateAddres(to: coordinate)
    }

}

//    private func bind() {
//          $coordinate
//            .compactMap { $0 }
//            .flatMap { coordinate in
//                print(coordinate)
//                return self.getPlaceMark(for: coordinate)
//                    .catch { error -> Just<CLPlacemark> in  // Catch errors.
//                        print("Failed with error: \(error)")
//                        return Just(self.defaultPlacemark)  // Provide a default value.
//                    }
//            }
//            .receive(on: RunLoop.main)
//            .sink { placemark in
//                let postalCode = placemark.postalCode ?? String()
//                let isoCountryCode = placemark.isoCountryCode ?? String()
//                let country = placemark.country ?? String()
//                let administrativeArea = placemark.administrativeArea ?? String()
//                let locality = placemark.locality ?? String()
//                let subLocality = placemark.subLocality ?? String()
//                let name = placemark.name ?? String()
//                let areasOfInterest = placemark.areasOfInterest ?? []
//                let subAdministrativeArea = placemark.subAdministrativeArea ?? String()
//                let inlandWater = placemark.inlandWater ?? String()
//                let ocean = placemark.ocean ?? String()
//                let thoroughfare = placemark.thoroughfare ?? String()
//                let subThoroughfare = placemark.subThoroughfare ?? String()
//
//                let infomation = """
//postalCode: \(postalCode)
//isoCountryCode: \(isoCountryCode)
//country: \(country)
//administrativeArea: \(administrativeArea)
//locality: \(locality)
//subLocality: \(subLocality)
//name: \(name)
//areasOfInterest: \(areasOfInterest)
//subAdministrativeArea: \(subAdministrativeArea)
//inlandWater: \(inlandWater)
//ocean: \(ocean)
//thoroughfare: \(thoroughfare)
//subThoroughfare: \(subThoroughfare)
//"""
//                self.infomationLabel.text = infomation
//
//                ///1.광역시, 특별시 등 도이름과 시이름이 같을 경우
//                ///2.name이 sublocality를 포함하는 경우
//                ///3.둘다인경우
//                if administrativeArea == locality && name.contains(subLocality) {
//                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(name)"
//                } else if administrativeArea == locality {
//                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(subLocality) \(name)"
//                } else if name.contains(subLocality) {
//                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(locality) \(name)"
//                } else {
//                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(locality) \(subLocality) \(name)"
//                }
//                self.addressLabel.text = "\(subThoroughfare) \(thoroughfare), \(locality), \(administrativeArea), \(postalCode), \(country)"
//            }.store(in: &subscriptions)
//    }
