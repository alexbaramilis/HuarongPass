//
//  SolvingIndicator.swift
//  华容道
//
//  Created by Alexandros Baramilis on 28/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import UIKit

/// A subclass of UIView that displays an activity indicator with a label underneath, on a transparent background with rounded corners.
class SolvingIndicator: UIView {
    class func instanceFromNib() -> SolvingIndicator {
        let solvingIndicator = UINib(nibName: "SolvingIndicator", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SolvingIndicator
        solvingIndicator.layer.cornerRadius = 15
        return solvingIndicator
    }
}
