//
//  Zobrist.swift
//  华容道
//
//  Created by Alexandros Baramilis on 26/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import Foundation

/// A class to implement Zobrist hashing: https://en.wikipedia.org/wiki/Zobrist_hashing
class Zobrist {
    private let columns: Int // the board columns
    private let rows: Int // the board rows
    private let cellStates: Int // the number of piece types, including the empty state
    private var randomBitstrings: [[[Int]]] // a 3D array (columns x rows x cellStates) that holds a random integer for every possible state of every cell of the board
    
    init(columns: Int, rows: Int, cellStates: Int) {
        self.columns = columns
        self.rows = rows
        self.cellStates = cellStates
        randomBitstrings = Array(repeating: Array(repeating: Array(repeating: 0, count: cellStates), count: rows), count: columns)
        // for every cell of the board and for every possible state of each cell, assign a random 64-bit integer
        for x in 0..<columns {
            for y in 0..<rows {
                for t in 0..<cellStates {
                    randomBitstrings[x][y][t] = Int.random(in: 1...9223372036854775807) // from 1 to 2^63 - 1 (inclusive)
                }
            }
        }
    }
    
    // used to calculate the hash (or hashMirror) of the initial board
    func getZobristHash(of board: Board, isMirror: Bool) -> Int {
        var hash = 0
        // for every cell of the board
        for x in 0..<columns {
            for y in 0..<rows {
                // get the piece index (subtract 1 to match the indexing of the pieces array)
                let pieceIndex = board.state[x + 1][y + 1] - 1
                // get the piece type
                // if the piece index is a valid pieces array index, get the type from the piece in the array
                // if not (the empty state will set the pieceIndex to -1), return 0 (the empty state)
                let type = pieceIndex >= 0 && pieceIndex < board.pieces.count ? board.pieces[pieceIndex].type.rawValue : 0
                // bitwise XOR between the hash and the random bitstring of the current cell and state
                // if it's the mirror hash, use the cell in the horizontally flipped board
                hash ^= randomBitstrings[isMirror ? x : columns - x - 1][y][type]
            }
        }
        return hash
    }
    
    // used to calculate the updated hash for the subsequent boards
    func getZobristHashUpdate(board: Board, pieceIndex: Int, directionIndex: Int, isMirror: Bool) -> Int {
        // get shorthand names for all the required values
        var hash = isMirror ? board.hashMirror : board.hash
        let piece = board.pieces[pieceIndex]
        let row = piece.position.y
        let col = isMirror ? columns - 1 - piece.position.x : piece.position.x
        let type = piece.type.rawValue
        let dx = isMirror ? -1 : 1
        let direction = Options.Directions[isMirror && directionIndex % 2 == 1 ? (directionIndex + 2) % 4 : directionIndex]
        let x = direction.x
        let y = direction.y
        // Depending on the piece type...
        // 1) XOR out the piece at the old position
        // -> XOR with the bitstring of the piece type for each cell occupied by the piece at the old position
        // -> XOR with the bitstring of the empty state for each cell occupied by the piece at the old position
        // 2) XOR in the piece at the new position
        // -> XOR with the bitstring of the empty state for each cell that will be occupied by the piece at the new position
        // -> XOR with the bitstring of the piece type for each cell that will be occupied by the piece at the new position
        switch piece.type {
        case .soldier:
            // XOR out the old position
            hash ^= randomBitstrings[col][row][type]
            hash ^= randomBitstrings[col][row][0]
            // XOR in the new position
            hash ^= randomBitstrings[col + x][row + y][0]
            hash ^= randomBitstrings[col + x][row + y][type]
        case .commanderVertical:
            // XOR out the old position
            hash ^= randomBitstrings[col][row][type]
            hash ^= randomBitstrings[col][row + 1][type]
            hash ^= randomBitstrings[col][row][0]
            hash ^= randomBitstrings[col][row + 1][0]
            // XOR in the new position
            hash ^= randomBitstrings[col + x][row + y][0]
            hash ^= randomBitstrings[col + x][row + y + 1][0]
            hash ^= randomBitstrings[col + x][row + y][type]
            hash ^= randomBitstrings[col + x][row + y + 1][type]
        case .commanderHorizontal:
            // XOR out the old position
            hash ^= randomBitstrings[col][row][type]
            hash ^= randomBitstrings[col + dx][row][type]
            hash ^= randomBitstrings[col][row][0]
            hash ^= randomBitstrings[col + dx][row][0]
            // XOR in the new position
            hash ^= randomBitstrings[col + x][row + y][0]
            hash ^= randomBitstrings[col + x + dx][row + y][0]
            hash ^= randomBitstrings[col + x][row + y][type]
            hash ^= randomBitstrings[col + x + dx][row + y][type]
        case .caocao:
            // XOR out the old position
            hash ^= randomBitstrings[col][row][type]
            hash ^= randomBitstrings[col + dx][row][type]
            hash ^= randomBitstrings[col][row + 1][type]
            hash ^= randomBitstrings[col + dx][row + 1][type]
            hash ^= randomBitstrings[col][row][0]
            hash ^= randomBitstrings[col + dx][row][0]
            hash ^= randomBitstrings[col][row + 1][0]
            hash ^= randomBitstrings[col + dx][row + 1][0]
            // XOR in the new position
            hash ^= randomBitstrings[col + direction.x][row + y][0]
            hash ^= randomBitstrings[col + direction.x + dx][row + y][0]
            hash ^= randomBitstrings[col + x][row + y + 1][0]
            hash ^= randomBitstrings[col + x + dx][row + y + 1][0]
            hash ^= randomBitstrings[col + x][row + y][type]
            hash ^= randomBitstrings[col + x + dx][row + y][type]
            hash ^= randomBitstrings[col + x][row + y + 1][type]
            hash ^= randomBitstrings[col + x + dx][row + y + 1][type]
        }
        return hash
    }
}
