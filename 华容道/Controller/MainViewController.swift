//
//  MainViewController.swift
//  华容道
//
//  Created by Alexandros Baramilis on 09/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import UIKit

/// The main view controller of the app. Corresponds to the first screen when opening the app.
class MainViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let options = Options.standardOptions() // see Options.swift for more details
    private let engine = HuarongEngine() // the engine that will solve the puzzle
    
    private var selectedPieces: [Piece] = [] // the pieces selected for the custom board
    private lazy var customBoard: CustomBoard = initCustomBoard() // the custom board view that contains the plus buttons and custom pieces
    private var solvingIndicator: SolvingIndicator = SolvingIndicator.instanceFromNib() // loading indicator view for when solving
    private var isSolving = false // the solving state (used to toggle the solving execution)
    
    // MARK: - Outlets
    
    @IBOutlet weak var boardTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var boardImageView: UIImageView!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    // MARK: - Actions
    
    // action when tapping on the segmented control that changes the board between standard and custom
    @IBAction func boardTypeChanged(_ sender: UISegmentedControl) {
        switch boardTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            customBoard.removeFromSuperview() // remove the custom board
            infoButton.isHidden = true // hide the info button
        case 1:
            view.addSubview(customBoard) // add the custom board
            infoButton.isHidden = false // show the info button
        default: break
        }
    }
    
    // button to start or cancel the solving execution
    @IBAction func solveButtonTapped(_ sender: UIButton) {
        toggleSolvingExecution()
    }
    
    // when tapping on the info button, show the info alert
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        showAlert(title: Text.CustomBoard, message: Text.CustomBoardInfo)
    }
    
    // MARK: - Navigation
    
    // navigates to the solution when the solving is completed and a solution is found
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueID = segue.identifier {
            switch segueID {
            case SegueID.ShowSolution:
                guard let solutionViewController = segue.destination as? SolutionViewController, let boards = sender as? [Board] else {
                    fatalError("Make sure SolutionViewController segue is setup properly.")
                }
                solutionViewController.boards = boards
                solutionViewController.options = options
            default: break
            }
        }
    }
    
    // MARK: - UI helper methods
    
    // toggles the UI between the solving state and the initial state
    // - disables the buttons when solving
    // - shows the solving indicator
    // - sets the title of the solve button to "Solve" or "Cancel"
    private func toggleSolvingUI(isSolving: Bool) {
        boardTypeSegmentedControl.isEnabled = !isSolving
        optionsButton.isEnabled = !isSolving
        infoButton.isEnabled = !isSolving
        solveButton.setTitle(isSolving ? Text.Cancel : Text.Solve, for: .normal)
        if isSolving {
            view.addSubview(solvingIndicator)
            solvingIndicator.center = boardImageView.center
        } else {
            solvingIndicator.removeFromSuperview()
        }
    }
    
    // helper method to present an alert to the user
    private func showAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Text.OK, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Solving execution
    
    // this method starts the solving execution and performs the appropriate actions when it's finished or cancelled
    private func toggleSolvingExecution() {
        guard boardIsValid() else { return } // check if the board is valid
        isSolving = !isSolving
        toggleSolvingUI(isSolving: isSolving)
        if isSolving {
            // choose the pieces: either the selected pieces from the custom board, or the standard pieces
            let pieces = boardTypeSegmentedControl.selectedSegmentIndex == 1 ? selectedPieces : Piece.standardPieces()
            // save the start time (used to calculate the execution time)
            let startTime = Date()
            // Start solving!
            engine.solve(with: pieces, options: options, completion: { [unowned self] path in
                // Calculate the seconds it took to run and print it in the console
                let seconds = (Date().timeIntervalSince(startTime)*1000.0).rounded()/1000.0
                print("Time: \(seconds) seconds")
                // Restore the UI
                self.isSolving = false
                self.toggleSolvingUI(isSolving: false)
                // If a solution was not found, show an alert and return
                guard let path = path else {
                    self.showAlert(message: Text.NoSolution)
                    return
                }
                // If a solution was found, print the number of moves
                print("Moves:", path.last!.step)
                // Also print the current setting (can be toggled from the Options menu in the app)
                print("(a two-block move in different directions is counted as " + (self.options.allowTwoBlockMoveInDifferentDirections ? "one step)" : "two steps)"))
                // Navigate to the solution screen
                self.performSegue(withIdentifier: SegueID.ShowSolution, sender: path)
            })
        } else {
            // Cancels the execution (UI alread restored above)
            engine.cancel()
        }
    }
    
    // Check if the board is valid before starting execution
    private func boardIsValid() -> Bool {
        // If it's the standard board, it's valid
        guard boardTypeSegmentedControl.selectedSegmentIndex == 1 else {
            return true
        }
        // If it's a custom board, check if it's empty or not
        guard !selectedPieces.isEmpty else {
            showAlert(title: nil, message: Text.AddPieces)
            return false
        }
        // Also check if it contains Cao Cao (the main piece that needs to go out of the exit)
        guard (selectedPieces.contains { $0.type == .caocao }) else {
            showAlert(title: nil, message: Text.AddCaoCao)
            return false
        }
        return true
    }
}

// MARK: - CustomBoard methods

extension MainViewController {
    // Initialise the custom board and set the frame and delegate
    private func initCustomBoard() -> CustomBoard {
        let customBoard = CustomBoard.instanceFromNib()
        // the custom board is placed on top of the full wooden board image to obscure the original pieces
        customBoard.frame = CGRect(x: boardImageView.frame.minX + 0.04 * boardImageView.bounds.width,
                                   y: boardImageView.frame.minY + 0.273 * boardImageView.bounds.height,
                                   width: 0.922 * boardImageView.bounds.width,
                                   height: 0.703 * boardImageView.bounds.height)
        customBoard.delegate = self
        return customBoard
    }
    
    // Try to add a piece to the custom board
    private func tryToAddPiece(pieceType: PieceType, position: (x: Int, y: Int)) {
        // create the Piece instance
        let piece = Piece(label: Piece.assignLabel(for: pieceType, currentPiecesOnBoard: selectedPieces), type: pieceType, position: position)
        // If it's a Cao Cao piece (the main piece that needs to exit), check if there is one already. (there can only be one Cao Cao!)
        guard !(piece.type == .caocao && selectedPieces.contains { $0.type == .caocao }) else {
            showAlert(title: nil, message: Text.OneCaoCao)
            return
        }
        // Check if the piece fits in the board (ie. doesn't hit the borders or other pieces)
        guard piece.fitsBoard(boardSize: (columns: options.boardColumns, rows: options.boardRows), currentPiecesOnBoard: selectedPieces) else {
            showAlert(title: nil, message: Text.PieceDoesntFit)
            return
        }
        // If it fits, append it the the selectedPiece array
        selectedPieces.append(piece)
        // Get the frame, make a CustomPiece and add it to the customBoard as a subview for display
        let pieceFrame = piece.getFrame(boardSize: (columns: options.boardColumns, rows: options.boardRows), boardBounds: customBoard.bounds)
        customBoard.addSubview(CustomPiece(frame: pieceFrame, associatedPiece: piece, delegate: self))
    }
}

// MARK: - CustomBoard delegate

extension MainViewController: CustomBoardDelegate {
    // If a plus button on the custom board was tapped, show an action sheet with options to choose from which piece type to add.
    // If a piece type is chosen, try to add the piece to the board at the specified position.
    func plusButtonTapped(tag: Int) {
        let actionSheet = UIAlertController(title: Text.AddPiece, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: Text.Soldier, style: .default, handler: { [weak self] _ in
            self?.tryToAddPiece(pieceType: .soldier, position: CustomBoard.PositionForTag[tag]!)
        }))
        actionSheet.addAction(UIAlertAction(title: Text.Commander1, style: .default, handler: { [weak self] _ in
            self?.tryToAddPiece(pieceType: .commanderVertical, position: CustomBoard.PositionForTag[tag]!)
        }))
        actionSheet.addAction(UIAlertAction(title: Text.Commander2, style: .default, handler: { [weak self] _ in
            self?.tryToAddPiece(pieceType: .commanderHorizontal, position: CustomBoard.PositionForTag[tag]!)
        }))
        actionSheet.addAction(UIAlertAction(title: Text.CaoCao, style: .default, handler: { [weak self] _ in
            self?.tryToAddPiece(pieceType: .caocao, position: CustomBoard.PositionForTag[tag]!)
        }))
        actionSheet.addAction(UIAlertAction(title: Text.Cancel, style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - CustomPiece delegate

extension MainViewController: CustomPieceDelegate {
    // If a custom piece was tapped, remove it from the board
    func didTap(piece: Piece, sender: CustomPiece) {
        if let index = selectedPieces.firstIndex(of: piece) { // get its index
            selectedPieces.remove(at: index) // remove it from selectedPieces
            sender.removeFromSuperview() // remove it from the customBoard
        }
    }
}
