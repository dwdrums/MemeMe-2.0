//
//  TabBarController.swift
//  MemeMe 2.0
//
//  Created by Daniel Schallmeiner on 02.04.20.
//  Copyright © 2020 otaxi GmbH. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.unselectedItemTintColor = UIColor.red
        self.tabBar.tintColor = UIColor.green
        self.tabBar.barTintColor = UIColor.black
        
    }
}
