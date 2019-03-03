//
//  CustomBoard.swift
//  华容道
//
//  Created by Alexandros Baramilis on 28/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import UIKit

protocol CustomBoardDelegate: class {
    func plusButtonTapped(tag: Int)
}

/// A subclass of UIView that represents the custom board. It contains a plus button for each cell, which is used to add pieces to the board. Each button contains an Int tag for identifying the corresponding position on the board. It also stores and displays custom pieces (CustomPiece) as subviews. When a button is tapped, the tag is passed back through the CustomBoardDelegate.
class CustomBoard: UIView {
    weak var delegate: CustomBoardDelegate?
    
    class func instanceFromNib() -> CustomBoard {
        let customBoard = UINib(nibName: "CustomBoard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomBoard
        customBoard.backgroundColor = Color.BoardBackground
        return customBoard
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        delegate?.plusButtonTapped(tag: sender.tag)
    }
}

extension CustomBoard {
    static let PositionForTag = [
        0: (x: 0, y: 0),
        1: (x: 1, y: 0),
        2: (x: 2, y: 0),
        3: (x: 3, y: 0),
        4: (x: 0, y: 1),
        5: (x: 1, y: 1),
        6: (x: 2, y: 1),
        7: (x: 3, y: 1),
        8: (x: 0, y: 2),
        9: (x: 1, y: 2),
        10: (x: 2, y: 2),
        11: (x: 3, y: 2),
        12: (x: 0, y: 3),
        13: (x: 1, y: 3),
        14: (x: 2, y: 3),
        15: (x: 3, y: 3),
        16: (x: 0, y: 4),
        17: (x: 1, y: 4),
        18: (x: 2, y: 4),
        19: (x: 3, y: 4),
    ]
}
