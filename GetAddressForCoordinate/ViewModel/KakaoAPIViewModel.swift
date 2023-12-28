//
//  KakaoAPIViewModel.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/28/23.
//

import Foundation
import CoreLocation

class KakaoAPIViewModel {
    @Published var coordinate: CLLocationCoordinate2D?
    let session = URLSession(configuration: .default)

    func load() {

    }
}
