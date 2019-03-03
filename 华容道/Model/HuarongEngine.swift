//
//  HuarongEngine.swift
//  华容道
//
//  Created by Alexandros Baramilis on 10/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import Foundation

/// The class that will manage the solving of the puzzle.
class HuarongEngine {
    
    // MARK: - Private properties
    
    private var options: Options! // the options for this solution
    private var zobrist: Zobrist! // the instance to hold the bitstrings and to calculate the Zobrist hashes
    private var boards: [Board]! // the array that stores all the possible new boards that are generated (and not visited before)
    private var visitedHashes: Set<Int>! // the hashes of the boards visited (including mirror boards if option enabled)
    private var caoCaoIndex: Int! // the index of the Cao Cao piece (main piece) in the pieces array
    private var workItem: DispatchWorkItem! // encapsulates the work of the engine to be run in different threads or cancelled
    
    // MARK: - Public methods
    
    // starts the solving execution and manages the threads
    func solve(with pieces: [Piece], options: Options, completion: @escaping ([Board]?) -> Void) {
        // setup the engine with the selected pieces and options
        setupEngine(with: pieces, options: options)
        // set the work item
        workItem = DispatchWorkItem { [weak self] in
            // this is run on the utility queue
            let path = self?.findPathToExit()
            // this is run on the main queue when the above code completes
            DispatchQueue.main.async {
                // if the work item has not been cancelled, i.e. the code has finished executing (with a solution or not)
                if self?.workItem.isCancelled == false {
                    print("Completed")
                    // call to completion closure
                    completion(path)
                }
                // reset the work item
                self?.workItem = nil
            }
        }
        // run the work item
        DispatchQueue.global(qos: .utility).async(execute: workItem)
    }
    
    // cancels the solving execution
    func cancel() {
        // this just sets the work item as cancelled, but does not stop execution once it has started
        // to stop the execution we need to add a check for workItem.isCancelled in the execution loop (i.e. in the while of findPathToExit())
        DispatchQueue.main.async { [weak workItem] in
            print("Cancelled")
            workItem?.cancel()
        }
    }
    
    // MARK: - Private methods
    
    // Setup game
    
    private func setupEngine(with pieces: [Piece], options: Options) {
        self.options = options
        zobrist = Zobrist(columns: options.boardColumns, rows: options.boardRows, cellStates: Piece.CellStates)
        boards = []
        visitedHashes = []
        setupInitialBoard(with: pieces) // sets up the board with the pieces in the initial positions
    }
    
    private func setupInitialBoard(with pieces: [Piece]) {
        // init an empty board
        let board = Board.initWithEmptyState(width: options.boardWidth, height: options.boardHeight)
        // place the pieces
        for (index, piece) in pieces.enumerated() {
            // set the index of the Cao Cao piece
            if piece.type == .caocao {
                caoCaoIndex = index
            }
            board.updateStateByAddingPiece(row: piece.position.y, column: piece.position.x, pieceType: piece.type, pieceIndex: index)
            board.pieces.append(piece)
        }
        // calculate the hash and of the original board and its mirror
        board.hash = zobrist.getZobristHash(of: board, isMirror: false)
        board.hashMirror = zobrist.getZobristHash(of: board, isMirror: true)
        // append the board to the boards array
        boards.append(board)
    }
    
    // Solve game
    
    // this is basically a breadth-first search that will analyse all the possible moves after each step before moving on to the next step
    // this is why it's guarranteed to find the shortest path (if there is one), or at least one of the shortest paths, as there can be many solutions with the same length
    // it's implemented here with an array acting as a queue, but keeping the dequeued elements instead of discarding them, so we can trace back our steps in the final solution. Using an index variable, we can move up the queue while new boards are added at the end, until a solution is found or we run out of boards to analyse.
    private func findPathToExit() -> [Board]? {
        var index = 0
        // if we have not reached the end of the possible boards and the execution has not been cancelled
        while index < boards.count && !workItem.isCancelled {
            let board = boards[index] // get the board
            index += 1 // increment the index
            updateVisitedHashes(with: board) // add the board hash (and hashMirror) to the visitedHashes set
            // if Cao Cao (the main piece) can escape through the exit, return the boards in the shortest path solution
            // if not, try to find new boards and add them to the queue (boards array)
            if board.caoCaoCanEscape(caoCaoIndex: caoCaoIndex, caoCaoFinalPosition: options.caoCaoFinalPosition) {
                return boardsOnShortestPath(from: board)
            } else {
                findNewBoards(from: board)
            }
        }
        return nil
    }
    
    private func updateVisitedHashes(with board: Board) {
        visitedHashes.insert(board.hash)
        if options.excludeMirrorBoards {
            visitedHashes.insert(board.hashMirror)
        }
    }
    
    // finds all the possible next boards from a given state
    private func findNewBoards(from board: Board) {
        // for each piece on the board
        for pieceIndex in 0..<board.pieces.count {
            // for each possible direction
            for directionIndex in 0..<Options.Directions.count {
                // try to move the piece in that direction
                tryMovingPiece(in: board, pieceIndex: pieceIndex, directionIndex: directionIndex)
            }
        }
    }
    
    // tries to move a piece in a certain direction as part of the first move of a double move
    private func tryMovingPiece(in board: Board, pieceIndex: Int, directionIndex firstMoveDirectionIndex: Int) {
        // if the first move was successful, add the board and try to move the piece again (if the piece can move again, another board will be added, but its step will be set to be the same as the first move)
        if let newBoard = addNewBoardByMovingPiece(in: board, pieceIndex: pieceIndex, directionIndex: firstMoveDirectionIndex) {
            // if the option to allow the block to move twice in different directions is true
            if options.allowTwoBlockMoveInDifferentDirections {
                // check if the piece can make its second move in any direction that is not the reverse of the previous direction (to avoid loops)
                for secondMoveDirectionIndex in 0..<Options.Directions.count where !Options.isReverseDirection(firstMoveDirectionIndex, secondMoveDirectionIndex) {
                    tryMovingPieceAgain(in: newBoard, pieceIndex: pieceIndex, directionIndex: secondMoveDirectionIndex)
                }
            } else {
                // if the option is false, try to move again in the same direction as the first move
                tryMovingPieceAgain(in: newBoard, pieceIndex: pieceIndex, directionIndex: firstMoveDirectionIndex)
            }
        }
    }
    
    // tries to move a piece as part of the second move of a double move
    private func tryMovingPieceAgain(in board: Board, pieceIndex: Int, directionIndex secondMoveDirectionIndex: Int) {
        // if the second move is successful, add the board and reduce the step by one, to match the step of the first move (so they're part of the same move)
        if let newBoard = addNewBoardByMovingPiece(in: board, pieceIndex: pieceIndex, directionIndex: secondMoveDirectionIndex) {
            newBoard.step -= 1
        }
    }
    
    // checks if a piece can move in a certain direction and if yes, adds the board to the boards array
    private func addNewBoardByMovingPiece(in board: Board, pieceIndex: Int, directionIndex: Int) -> Board? {
        // if the piece can move
        if board.canPieceMove(pieceIndex: pieceIndex, directionIndex: directionIndex) {
            // get the Zobrist hash for the new state (after the move)
            let hash = zobrist.getZobristHashUpdate(board: board, pieceIndex: pieceIndex, directionIndex: directionIndex, isMirror: false)
            // if the hash is already in the set (means the board was already visited), return nil
            if visitedHashes.contains(hash) {
                return nil
            }
            var hashMirror = 0
            // if the option to exclude mirror boards is set
            if options.excludeMirrorBoards {
                // get the Zobrist hash of the mirror board of the new state (after the move)
                hashMirror = zobrist.getZobristHashUpdate(board: board, pieceIndex: pieceIndex, directionIndex: directionIndex, isMirror: true)
                // if the hash is already in the set, return nil
                if visitedHashes.contains(hashMirror) {
                    return nil
                }
            }
            // create the new board by copying the original board (creates a new instance in memory)
            let newBoard = board.copy()
            // get the corresponding piece of the new board
            let piece = newBoard.pieces[pieceIndex]
            let direction = Options.Directions[directionIndex]
            // remove the piece from the new board state
            newBoard.updateStateByRemovingPiece(row: piece.position.y, column: piece.position.x, pieceType: piece.type)
            // update the piece position
            piece.position.y += direction.y
            piece.position.x += direction.x
            // update the state with the new piece
            newBoard.updateStateByAddingPiece(row: piece.position.y, column: piece.position.x, pieceType: piece.type, pieceIndex: pieceIndex)
            // update the pieces array with the new piece
            newBoard.pieces[pieceIndex] = piece
            // increment the step by one
            newBoard.step = board.step + 1
            // set the previous board as the parent
            newBoard.parent = board
            // set the hashes
            newBoard.hash = hash
            if options.excludeMirrorBoards {
                newBoard.hashMirror = hashMirror
            }
            // update the visitedHashes set
            updateVisitedHashes(with: newBoard)
            // append the new board to the boards array
            boards.append(newBoard)
            return newBoard
        }
        return nil
    }
    
    // from a given board, trace back the steps in the shortest path and return the boards of the shortest path in an array
    private func boardsOnShortestPath(from finalBoard: Board) -> [Board] {
        // initialise an empty array
        var boardsOnShortestPath = [Board]()
        // start the board variable with the final board
        var board: Board? = finalBoard
        // while the current board is not nil (it will be nil once it's set to the parent of the original board)
        while board != nil {
            // append the board on the shortest path (it will hold the boards from end to beginning)
            boardsOnShortestPath.append(board!)
            // if it has a parent with the same step (because it was part of a double move)
            if board!.parent != nil && board!.step == board!.parent!.step {
                // set the current board to the parent of the parent (we skip the parent since it's in the same step)
                board = board!.parent!.parent
            } else {
                // else, just set the current board to the parent
                board = board!.parent
            }
        }
        // return the boards on the shortest path in a reversed order, so the order is from beginning to end
        return boardsOnShortestPath.reversed()
    }
}
