//
//  Options.swift
//  华容道
//
//  Created by Alexandros Baramilis on 26/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import Foundation

/// A class to hold certain values and settings for the game.
class Options {
    let boardColumns: Int
    let boardRows: Int
    
    var boardWidth: Int { return boardColumns + 2 } // the columns + the borders
    var boardHeight: Int { return boardRows + 2 } // the rows + the borders
    
    let caoCaoFinalPosition: (x: Int, y: Int) // the position where Cao Cao needs to be to exit the board
    
    let excludeMirrorBoards: Bool // option to exclude mirror boards (horizontally flipped) from the search tree
    
    var allowTwoBlockMoveInDifferentDirections: Bool { // check the Options menu in the app for a more detailed description
        // if the key doesn't exist (ex. hasn't been set yet), it will return false, which is the default setting
        return UserDefaults.standard.bool(forKey: UserDefaultsKey.AllowTwoBlockMoveInDifferentDirections)
    }
    
    // the possible move directions (x axis points to the right, y axis points down)
    static let Directions = [(x: 0, y: 1), (x: 1, y: 0), (x: 0, y: -1), (x: -1, y: 0)] // down, right, up, left
    
    init(columns: Int, rows: Int, caoCaoFinalPosition: (x: Int, y: Int), excludeMirrorBoards: Bool) {
        self.boardColumns = columns
        self.boardRows = rows
        self.caoCaoFinalPosition = caoCaoFinalPosition
        self.excludeMirrorBoards = excludeMirrorBoards
    }
    
    // check if the two directions are opposite to each other
    static func isReverseDirection(_ directionIndex1: Int, _ directionIndex2: Int) -> Bool {
        return (directionIndex1 + 2) % Options.Directions.count == directionIndex2
    }
    
    // the default options
    static func standardOptions() -> Options {
        return Options(columns: 4, rows: 5, caoCaoFinalPosition: (x: 1, y: 3), excludeMirrorBoards: true)
    }
}
