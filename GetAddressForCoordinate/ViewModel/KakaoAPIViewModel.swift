//
//  KakaoAPIViewModel.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/28/23.
//

import Foundation
import CoreLocation
import Combine

class KakaoAPIViewModel {
    let networkService: NetworkService
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var addressName: String?
    var subscriptions = Set<AnyCancellable>()
    init(configuration: URLSessionConfiguration) {
        networkService = NetworkService(configuration: configuration)
    }

    func updateAddress(from coordinate: CLLocationCoordinate2D) {
        networkService.load(resource(coordinate))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { request in
                self.addressName = request.documents.first?.address.address_name
            }.store(in: &subscriptions)

        func resource(_ coordinate: CLLocationCoordinate2D) -> Resource<KakaoAPIRequest> {
            let resource = Resource<KakaoAPIRequest>(base: "https://dapi.kakao.com/v2/local/geo/coord2address",
                                                     path: "",
                                                     params: [
                                                        "x": "\(coordinate.longitude)",
                                                        "y": "\(coordinate.latitude)"
                                                     ],
                                                     header: [
                                                        "Content-type": "content-type: application/json;charset=UTF-8",
                                                        "Authorization": "KakaoAK \(kakaoAPIKey)"
                                                     ],
                                                     httpMethod: .get)
            return resource
        }
    }
}
