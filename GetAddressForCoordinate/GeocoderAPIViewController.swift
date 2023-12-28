//
//  ViewController.swift
//  MapPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/22.
//

import UIKit
import MapKit
import CoreLocation
import Combine

/// "1600 Pennsylvania Ave NW, Washington, DC, 20500"
class GeocoderAPIViewController: UIViewController {

    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()

    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    let infomationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    @Published var coordinate: CLLocationCoordinate2D?

    let defaultPlacemark: CLPlacemark = {
        let location = CLLocation(latitude: 37.5665, longitude: 126.9780) // 서울 좌표
        let placemark = MKPlacemark(coordinate: location.coordinate)
        return placemark
    }()

    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setConstrains()
        addTapGestureToMapView()
        bind()

//        let identifier = Locale.current.identifier
//        guard let regionCode = Locale.current.region?.identifier else { return }
//        guard let languageCode = Locale.current.language.languageCode?.identifier else { return }
//        print("identifier = \(identifier), region = \(regionCode), language = \(languageCode)")
    }

    private func setConstrains() {
        view.addSubview(mapView)
        view.addSubview(infomationLabel)
        view.addSubview(addressLabel)

        NSLayoutConstraint.activate([
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 1),

            infomationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infomationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            infomationLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 30),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            addressLabel.topAnchor.constraint(equalTo: infomationLabel.bottomAnchor, constant: 30),
            addressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func bind() {
          $coordinate
            .compactMap { $0 }
            .flatMap { coordinate in
                print(coordinate)
                return self.getPlaceMark(for: coordinate)
                    .catch { error -> Just<CLPlacemark> in  // Catch errors.
                        print("Failed with error: \(error)")
                        return Just(self.defaultPlacemark)  // Provide a default value.
                    }
            }
            .receive(on: RunLoop.main)
            .sink { placemark in
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

                let infomation = """
postalCode: \(postalCode)
isoCountryCode: \(isoCountryCode)
country: \(country)
administrativeArea: \(administrativeArea)
locality: \(locality)
subLocality: \(subLocality)
name: \(name)
areasOfInterest: \(areasOfInterest)
subAdministrativeArea: \(subAdministrativeArea)
inlandWater: \(inlandWater)
ocean: \(ocean)
thoroughfare: \(thoroughfare)
subThoroughfare: \(subThoroughfare)
"""
                self.infomationLabel.text = infomation

                ///1.광역시, 특별시 등 도이름과 시이름이 같을 경우
                ///2.name이 sublocality를 포함하는 경우
                ///3.둘다인경우
                if administrativeArea == locality && name.contains(subLocality) {
                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(name)"
                } else if administrativeArea == locality {
                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(subLocality) \(name)"
                } else if name.contains(subLocality) {
                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(locality) \(name)"
                } else {
                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(locality) \(subLocality) \(name)"
                }
                self.addressLabel.text = "\(subThoroughfare) \(thoroughfare), \(locality), \(administrativeArea), \(postalCode), \(country)"
            }.store(in: &subscriptions)
    }

    private func getPlaceMark(for coordinate: CLLocationCoordinate2D) -> Future<CLPlacemark, Error> {

        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return Future() { promise in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in

                ///1. Placemarks가 nil일 경우 (장소에 대한 정보가 전혀 없음)
                ///2. 정보를 가져오는 과정에서  error가 있을 경우
                if let error = error {
                    promise(.failure(error))
                    return
                }

                ///Placemarks가 nil이 아니지만, 빈배열일 경우
                guard let placemark = placemarks?.first else {
                    promise(.failure(CLError(.geocodeFoundNoResult)))
                    return
                }

                promise(.success(placemark))
            }
        }
    }

    private func addTapGestureToMapView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
//        longPressGesture.minimumPressDuration = 0.3 // 사용자가 화면을 길게 누르는 최소 시간 설정
        mapView.addGestureRecognizer(tapGesture)
    }

    @objc func mapTapped(_ gestureRecognizer : UITapGestureRecognizer) {
        if gestureRecognizer.state != .ended { return }

         let touchPoint = gestureRecognizer.location(in: mapView)
         let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        self.coordinate = coordinate
        print(coordinate)
     }
}

//외국 주소
/// subThoroughfare thoroughfare, locality, administrativeArea, postalCode, country
