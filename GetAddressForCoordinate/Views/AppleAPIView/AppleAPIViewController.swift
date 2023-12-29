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
