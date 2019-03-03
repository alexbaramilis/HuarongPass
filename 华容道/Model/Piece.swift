//
//  Piece.swift
//  华容道
//
//  Created by Alexandros Baramilis on 26/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import UIKit

// the piece types and their corresponding indexes
enum PieceType: Int {
    case soldier = 1 // width: 1, height: 1
    case commanderVertical = 2 // width: 1, height: 2
    case commanderHorizontal = 3 // width: 2, height: 1
    case caocao = 4 // width: 2, height: 2
}

/// A class to represent a board piece.
class Piece {
    let imageName: String // The asset name of the image that will be displayed for that piece
    let type: PieceType
    var position: (x: Int, y: Int) // the position of its top left corner on the board (x increases to the right, y increases to the bottom)
    
    static let BorderIndex = -1 // the index to represent a border
    static let EmptyCellIndex = 0 // the index to represent an empty cell
    static let CellStates = 5 // the number of possible cell states = number of piece types + the empty state
    
    // returns the size of each piece, indexed by its piece type
    static let SizeForType = [
        1: (width: 1, height: 1),
        2: (width: 1, height: 2),
        3: (width: 2, height: 1),
        4: (width: 2, height: 2)
    ]
    
    init(label: String, type: PieceType, position: (x: Int, y: Int)) {
        self.imageName = label
        self.type = type
        self.position = position
    }
    
    // returns a copy of the piece (with different address in memory)
    func copy() -> Piece {
        return Piece(label: imageName, type: type, position: position)
    }
    
    // check if a piece fits the board (used for validation when placing pieces on the custom board)
    // a piece is placed by the top left corner on the board so we only need to do the checks below
    func fitsBoard(boardSize: (columns: Int, rows: Int), currentPiecesOnBoard: [Piece]) -> Bool {
        return !(position.x + Piece.SizeForType[type.rawValue]!.width > boardSize.columns || // doesn't hit the right border
                position.y + Piece.SizeForType[type.rawValue]!.height > boardSize.rows || // doesn't hit the bottom border
                intersects(pieces: currentPiecesOnBoard)) // doesn't hit other pieces
    }
    
    // check if a piece intersects any of the other pieces in the array
    private func intersects(pieces: [Piece]) -> Bool {
        // get the position and size of the piece
        let x = position.x
        let y = position.y
        let w = Piece.SizeForType[type.rawValue]!.width
        let h = Piece.SizeForType[type.rawValue]!.height
        for otherPiece in pieces {
            // get the position and size of the other piece
            let ox = otherPiece.position.x
            let oy = otherPiece.position.y
            let ow = Piece.SizeForType[otherPiece.type.rawValue]!.width
            let oh = Piece.SizeForType[otherPiece.type.rawValue]!.height
            // if the piece intersects with the other piece, return true
            if !(x + w <= ox || y + h <= oy || ox + ow <= x || oy + oh <= y) {
                return true
            }
        }
        return false // if it hasn't intersected with any pieces, return false
    }
    
    // translates the piece position into a UI frame
    func getFrame(boardSize: (columns: Int, rows: Int), boardBounds: CGRect) -> CGRect {
        let x = CGFloat(position.x) / CGFloat(boardSize.columns) * boardBounds.width
        let y = CGFloat(position.y) / CGFloat(boardSize.rows) * boardBounds.height
        let w = CGFloat(Piece.SizeForType[type.rawValue]!.width) / CGFloat(boardSize.columns) * boardBounds.width
        let h = CGFloat(Piece.SizeForType[type.rawValue]!.height) / CGFloat(boardSize.rows) * boardBounds.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    // assigns a label to the piece based on its type and the current pieces on the board
    // if it runs out of labels, it starts again from the beginning
    static func assignLabel(for pieceType: PieceType, currentPiecesOnBoard: [Piece]) -> String {
        switch pieceType {
        case .soldier: return "soldier_" + String(currentPiecesOnBoard.filter { $0.type == .soldier }.count % 4 + 1)
        case .commanderVertical: return "commander_vertical_" + String(currentPiecesOnBoard.filter { $0.type == .commanderVertical }.count % 4 + 1)
        case .commanderHorizontal: return "commander_horizontal"
        case .caocao: return "cao_cao"
        }
    }
    
    // the default pieces for the standard board
    static func standardPieces() -> [Piece] {
        return [Piece(label: "commander_vertical_1", type: .commanderVertical, position: (x: 0, y: 0)),
                Piece(label: "cao_cao", type: .caocao, position: (x: 1, y: 0)),
                Piece(label: "commander_vertical_2", type: .commanderVertical, position: (x: 3, y: 0)),
                Piece(label: "commander_vertical_3", type: .commanderVertical, position: (x: 0, y: 2)),
                Piece(label: "commander_horizontal", type: .commanderHorizontal, position: (x: 1, y: 2)),
                Piece(label: "commander_vertical_4", type: .commanderVertical, position: (x: 3, y: 2)),
                Piece(label: "soldier_1", type: .soldier, position: (x: 0, y: 4)),
                Piece(label: "soldier_2", type: .soldier, position: (x: 1, y: 3)),
                Piece(label: "soldier_3", type: .soldier, position: (x: 2, y: 3)),
                Piece(label: "soldier_4", type: .soldier, position: (x: 3, y: 4))]
    }
}

// Equatable protocol conformance -> answers the question: when are two Piece objects equal?
extension Piece: Equatable {
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.position.x == rhs.position.x && lhs.position.y == rhs.position.y
    }
}
