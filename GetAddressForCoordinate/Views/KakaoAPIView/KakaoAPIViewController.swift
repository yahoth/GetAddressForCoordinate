//
//  KakaoAPIViewController.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/28/23.
//

import UIKit
import Combine
import CoreLocation

class KakaoAPIViewController: BaseViewController {

    var session: URLSession!
    var vm: KakaoAPIViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = KakaoAPIViewModel(configuration: .default)
        bind()
    }

    func bind() {
        vm.$addressName
            .receive(on: DispatchQueue.main)
            .sink { address in
                self.addressLabel.text = address
            }.store(in: &subscriptions)
    }

    override func coordinateChanged(to coordinate: CLLocationCoordinate2D) {
        vm.updateAddress(from: coordinate)
    }
}
