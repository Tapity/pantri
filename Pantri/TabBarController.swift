//
//  tabBarController.swift
//  Pantri
//
//  Created by Mariah Olson on 4/16/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make unselected icons white
        self.tabBar.unselectedItemTintColor = UIColor(red: 0.4588, green: 0.1961, blue: 0, alpha: 1.0) /* #753200 */
    }
}
