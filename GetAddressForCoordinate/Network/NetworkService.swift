//
//  NetworkService.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/29/23.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidRequest
    case responseError(statusCode: Int)
}

class NetworkService {
    let session: URLSession

    init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }

    func load<T>(_ resoure: Resource<T>) -> AnyPublisher<T, Error> {
        guard let request = resoure.request else {
            return Fail(error: NetworkError.invalidRequest)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                    let response = result.response as? HTTPURLResponse
                    let statusCode = response?.statusCode ?? -1
                    throw NetworkError.responseError(statusCode: statusCode)
                }

                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
