//
//  Constants.swift
//  华容道
//
//  Created by Alexandros Baramilis on 09/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import UIKit

enum SegueID {
    static let ShowOptions = "ShowOptions"
    static let ShowSolution = "ShowSolution"
}

enum Color {
    static let Green = UIColor(red: 62.0/255.0, green: 73.0/255.0, blue: 49.0/255.0, alpha: 1.0)
    static let BoardBackground = UIColor(red: 54.0/255.0, green: 29.0/255.0, blue: 21.0/255.0, alpha: 1.0)
}

enum UserDefaultsKey {
    static let AllowTwoBlockMoveInDifferentDirections = "AllowTwoBlockMoveInDifferentDirections"
}
