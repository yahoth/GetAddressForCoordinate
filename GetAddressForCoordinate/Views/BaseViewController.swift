//
//  BaseViewController.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/28/23.
//

import UIKit
import MapKit
import Combine

import SnapKit

class BaseViewController: UIViewController {

    var mapView: MKMapView!
    var addressLabel: UILabel!
    @Published var coordinate: CLLocationCoordinate2D?
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setMapView()
        setAddressLabel()
        addTapGestureToMapView()
//        bind()
    }

//    func bind() {
//        vm.$coordinate
//            .receive(on: DispatchQueue.main)
//            .sink { coordinate in
//                self.reverseGeocoder()
//            }.store(in: &subscriptions)
//    }

//    func reverseGeocoder() {
//
//    }

    func setAddressLabel() {
        addressLabel = UILabel()
        addressLabel.font = .systemFont(ofSize: 20)
        addressLabel.textColor = .label
        addressLabel.textAlignment = .center
        view.addSubview(addressLabel)
        setAddressLabelConstraints()

        func setAddressLabelConstraints() {
            addressLabel.snp.makeConstraints { make in
                make.top.equalTo(mapView.snp.bottom).offset(20)
                make.horizontalEdges.equalTo(view).inset(50)
            }
        }
    }


    func setMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        setMapViewConstraints()

        func setMapViewConstraints() {
            mapView.snp.makeConstraints { make in
                make.top.leading.trailing.equalTo(view)
                make.height.equalTo(view.snp.width)
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

extension BaseViewController: MKMapViewDelegate {

}
