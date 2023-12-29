//
//  Resource.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/29/23.
//

import Foundation

struct Resource<T: Decodable> {
    let base: String
    let path: String
    let params: [String: String]
    let header: [String: String]
    let httpMethod: HTTPMethod
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    var request: URLRequest? {
        var urlComponets = URLComponents(string: base + path)!
        let queryItems = params.map { (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        }
        urlComponets.queryItems = queryItems

        var request = URLRequest(url: urlComponets.url!)
        header.forEach { (key: String, value: String) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = httpMethod.rawValue

        return request
    }

    init(base: String, path: String, params: [String : String] = [:], header: [String : String] = [:], httpMethod: HTTPMethod) {
        self.base = base
        self.path = path
        self.params = params
        self.header = header
        self.httpMethod = httpMethod
    }
}
