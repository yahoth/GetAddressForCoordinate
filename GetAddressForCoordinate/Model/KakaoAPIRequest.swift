//
//  KakaoAPIRequest.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/28/23.
//

import Foundation

struct KakaoAPIRequest: Codable {
    let documents: [Document]
}

struct Document: Codable {
    let address: Address
}

struct Address: Codable {
    let address_name: String
    let region_1depth_name: String
    let region_2depth_name: String
    let region_3depth_name: String
    let mountain_yn: String
    let main_address_no: String
    let sub_address_no: String
}
