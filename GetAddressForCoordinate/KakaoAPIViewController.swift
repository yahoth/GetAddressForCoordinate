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

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    func bind() {
        $coordinate
            .compactMap { $0 }
            .sink { coordinate in
                self.request(coordinate)
            }.store(in: &subscriptions)
    }

    func request(_ coordinate: CLLocationCoordinate2D) {
        session = URLSession(configuration: .default)
        let base = "https://dapi.kakao.com/v2/local/geo/coord2address"
        let path = ""
        let params: [String: String] = [
            "x": "\(coordinate.longitude)",
            "y": "\(coordinate.latitude)"
        ]

        let header: [String: String] = [
            "Content-type": "content-type: application/json;charset=UTF-8",
            "Authorization": "KakaoAK \(kakaoAPIKey)"
        ]

        let method = "GET"

        var urlComponets = URLComponents(string: base + path)!
        let queryItems = params.map { (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        }
        urlComponets.queryItems = queryItems

        var request = URLRequest(url: urlComponets.url!)
        header.forEach { (key: String, value: String) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = method

       session.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.global())
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode)
                else {
                    let response = result.response as? HTTPURLResponse
                    let statusCode = response?.statusCode ?? -1
                    print(statusCode)
                    return Data()
                }

                return result.data
            }
            .decode(type: KakaoAPIRequest.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { request in
                self.addressLabel.text = request.documents.first?.address.address_name
            }.store(in: &subscriptions)
    }


}
