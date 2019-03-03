//
//  Board.swift
//  华容道
//
//  Created by Alexandros Baramilis on 26/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import Foundation

/// A class to represent a board for a certain state of the game
class Board {
    // the state of the board *including the borders!*
    // stores the piece indexes (or border/empty index), indexed by their current positions
    // to get a piece based on its current position on the board we need to add +1 to the position to avoid the borders
    // i.e. [x+1][y+1] for a piece in the (x, y) position
    var state: [[Int]]
    var pieces: [Piece] // the pieces currently on the board
    var step: Int // the number of steps needed to reach this state, starting from the original board
    var hash: Int // the Zobrist hash of the board (a hash to uniquely identify this state of the board)
    var hashMirror: Int // the Zobrist hash of the horizontally flipped board (used to exlcude mirror boards from the search)
    var parent: Board? // the board before the move that led to the current board
    
    init(state: [[Int]], pieces: [Piece], step: Int, hash: Int, hashMirror: Int, parent: Board?) {
        self.state = state
        self.pieces = pieces
        self.step = step
        self.hash = hash
        self.hashMirror = hashMirror
        self.parent = parent
    }
    
    // returns a copy of the board (i.e. the same board but with a different location in memory)
    func copy() -> Board {
        return Board(state: state, pieces: pieces.map { $0.copy() }, step: step, hash: hash, hashMirror: hashMirror, parent: parent)
    }
    
    // initialise an empty board
    static func initWithEmptyState(width: Int, height: Int) -> Board {
        let board = Board(state: [[Int]](), pieces: [], step: 0, hash: 0, hashMirror: 0, parent: nil)
        var state = Array(repeating: Array(repeating: 0, count: height), count: width)
        // set the empty cells
        for x in 0..<width {
            for y in 0..<height {
                state[x][y] = Piece.EmptyCellIndex
            }
        }
        // set the top and bottom borders
        for x in 0..<width {
            state[x][0] = Piece.BorderIndex
            state[x][height - 1] = Piece.BorderIndex
        }
        // set the left and right borders
        for y in 1..<height - 1 {
            state[0][y] = Piece.BorderIndex
            state[width - 1][y] = Piece.BorderIndex
        }
        board.state = state
        return board
    }
    
    // add a piece at the specified row and column of the state board. occupy the rest of the cells based on the piece size.
    func updateStateByAddingPiece(row: Int, column: Int, pieceType: PieceType, pieceIndex: Int) {
        switch pieceType {
        case .soldier:
            state[column + 1][row + 1] = pieceIndex + 1
        case .commanderVertical:
            state[column + 1][row + 1] = pieceIndex + 1
            state[column + 1][row + 2] = pieceIndex + 1
        case .commanderHorizontal:
            state[column + 1][row + 1] = pieceIndex + 1
            state[column + 2][row + 1] = pieceIndex + 1
        case .caocao:
            state[column + 1][row + 1] = pieceIndex + 1
            state[column + 2][row + 1] = pieceIndex + 1
            state[column + 1][row + 2] = pieceIndex + 1
            state[column + 2][row + 2] = pieceIndex + 1
        }
    }
    
    // remove a piece from the state board at the specified row and column. clear the rest of the cells based on the piece size.
    func updateStateByRemovingPiece(row: Int, column: Int, pieceType: PieceType) {
        // basically add a piece with the empty cell index - 1 (since addPiece will add +1 to match the piece indexes)
        updateStateByAddingPiece(row: row, column: column, pieceType: pieceType, pieceIndex: Piece.EmptyCellIndex - 1)
    }
    
    // check if a piece can move in the specified direction
    func canPieceMove(pieceIndex: Int, directionIndex: Int) -> Bool {
        var canMove = false
        let piece = pieces[pieceIndex]
        let direction = Options.Directions[directionIndex] // get the direction using the direction index
        // get the state of the cells that will be occupied if the piece moves (current position + the moving direction)
        // if the states are empty or contain the current piece, the piece can move
        switch piece.type {
        case .soldier:
            let newCellState1 = state[piece.position.x + direction.x + 1][piece.position.y + direction.y + 1]
            canMove =
                newCellState1 == Piece.EmptyCellIndex
        case .commanderVertical:
            let newCellState1 = state[piece.position.x + direction.x + 1][piece.position.y + direction.y + 1]
            let newCellState2 = state[piece.position.x + direction.x + 1][piece.position.y + direction.y + 2]
            canMove =
                (newCellState1 == Piece.EmptyCellIndex || newCellState1 == pieceIndex + 1) &&
                (newCellState2 == Piece.EmptyCellIndex || newCellState2 == pieceIndex + 1)
        case .commanderHorizontal:
            let newCellState1 = state[piece.position.x + direction.x + 1][piece.position.y + direction.y + 1]
            let newCellState2 = state[piece.position.x + direction.x + 2][piece.position.y + direction.y + 1]
            canMove =
                (newCellState1 == Piece.EmptyCellIndex || newCellState1 == pieceIndex + 1) &&
                (newCellState2 == Piece.EmptyCellIndex || newCellState2 == pieceIndex + 1)
        case .caocao:
            let newCellState1 = state[piece.position.x + direction.x + 1][piece.position.y + direction.y + 1]
            let newCellState2 = state[piece.position.x + direction.x + 1][piece.position.y + direction.y + 2]
            let newCellState3 = state[piece.position.x + direction.x + 2][piece.position.y + direction.y + 1]
            let newCellState4 = state[piece.position.x + direction.x + 2][piece.position.y + direction.y + 2]
            canMove =
                (newCellState1 == Piece.EmptyCellIndex || newCellState1 == pieceIndex + 1) &&
                (newCellState2 == Piece.EmptyCellIndex || newCellState2 == pieceIndex + 1) &&
                (newCellState3 == Piece.EmptyCellIndex || newCellState3 == pieceIndex + 1) &&
                (newCellState4 == Piece.EmptyCellIndex || newCellState4 == pieceIndex + 1)
        }
        return canMove
    }
    
    // check if Cao Cao is in the final position
    func caoCaoCanEscape(caoCaoIndex: Int, caoCaoFinalPosition: (x: Int, y: Int)) -> Bool {
        return pieces[caoCaoIndex].position.x == caoCaoFinalPosition.x && pieces[caoCaoIndex].position.y == caoCaoFinalPosition.y
    }
}
