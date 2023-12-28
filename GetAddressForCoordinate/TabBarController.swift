//
//  TabBarController.swift
//  GetAddressForCoordinate
//
//  Created by TAEHYOUNG KIM on 12/28/23.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let geocoderVC = GeocoderAPIViewController()
        geocoderVC.tabBarItem = UITabBarItem(title: "Apple API", image: UIImage(systemName: "apple.logo"), tag: 0)

        let kakaoVC = KakaoAPIViewController()
        kakaoVC.tabBarItem = UITabBarItem(title: "Kakao API", image: UIImage(systemName: "map"), tag: 1)

        self.viewControllers = [geocoderVC, kakaoVC]
    }
}
