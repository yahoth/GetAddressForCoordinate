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

class ViewController: UIViewController {

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
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setConstrains()
        addGestureToMapView()
        bind()
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
            }
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed with error: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { placemark in
                let postalCode = placemark.postalCode ?? "-"
                let isoCountryCode = placemark.isoCountryCode ?? "-"
                let country = placemark.country ?? "-"
                let administrativeArea = placemark.administrativeArea ?? "-"
                let locality = placemark.locality ?? "-"
                let subLocality = placemark.subLocality ?? "-"
                let name = placemark.name ?? "-"
                let areasOfInterest = placemark.areasOfInterest ?? ["-"]
                let subAdministrativeArea = placemark.subAdministrativeArea ?? "-"
                let inlandWater = placemark.inlandWater ?? "-"
                let ocean = placemark.ocean ?? "-"

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
"""
                self.infomationLabel.text = infomation

                ///1.광역시, 특별시 등 도이름과 시이름이 같을 경우
                ///2.name이 sublocality를 포함하는 경우
                ///3.둘다인경우
                if administrativeArea == locality && name.contains(subLocality) {
                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(name), \(postalCode)"
                } else if administrativeArea == locality {
                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(subLocality) \(name), \(postalCode)"
                } else if name.contains(subLocality) {
                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(locality) \(name), \(postalCode)"
                } else {
                    self.addressLabel.text = "\(country) \(administrativeArea) \(subAdministrativeArea) \(locality) \(subLocality) \(name), \(postalCode)"
                }
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
                    print("1")
                    promise(.failure(error))
                    return
                }

                ///Placemarks가 nil이 아니지만, 빈배열일 경우
                guard let placemark = placemarks?.first else {
                        print("2")
                    promise(.failure(CLError(.geocodeFoundNoResult)))
                    return
                }

                promise(.success(placemark))
            }
        }
    }

    private func addGestureToMapView() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3 // 사용자가 화면을 길게 누르는 최소 시간 설정
        mapView.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongPress(_ gestureRecognizer : UILongPressGestureRecognizer) {
         if gestureRecognizer.state != .began { return }

         let touchPoint = gestureRecognizer.location(in: mapView)
         let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        self.coordinate = coordinate
     }
}

