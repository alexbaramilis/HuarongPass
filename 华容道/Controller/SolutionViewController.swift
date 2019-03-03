//
//  SolutionViewController.swift
//  华容道
//
//  Created by Alexandros Baramilis on 11/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import UIKit

/// The solutions view controller that will display the boards in the shortest path.
class SolutionViewController: UIViewController {
    
    // MARK: - Dependencies
    
    var boards: [Board]! // an array containing the boards of the shortest path
    var options: Options! // the options passed in from main controller
    
    // MARK: - Private properties
    
    private var currentStep: Int = 0 // current step of the solution
    private var boardView: UIView! // view that contains the board pieces
    
    // MARK: - Outlets
    
    @IBOutlet weak var totalStepsLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var boardImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
    
    // MARK: - Actions
    
    // dismiss the solution screen and move back to the original screen
    @IBAction func xButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // go to the previous step
    @IBAction func leftArrowTapped(_ sender: UIButton) {
        guard currentStep > 0 else { return }
        currentStep -= 1
        updateStepsLabel()
        updateBoard()
    }
    
    // go to the next step
    @IBAction func rightArrowTapped(_ sender: UIButton) {
        guard currentStep < boards.count - 1 else { return }
        currentStep += 1
        updateStepsLabel()
        updateBoard()
    }
    
    // MARK: - UI helper methods
    
    private func setupUI() {
        totalStepsLabel.text = Text.ShortestPath_Chinese + " \(boards.last!.step) " + Text.Steps_Chinese + "\n"
            + Text.ShortestPath_English + " \(boards.last!.step) " + Text.Steps_English
        addBoardView()
        updateBoard()
    }
    
    // adds the board view that will contain the pieces
    private func addBoardView() {
        // the board view is displayed on top of the original wooden board image to obscure the original pieces and display the custom pieces
        boardView = UIView(frame: CGRect(x: 0.04 * boardImageView.bounds.width,
                                         y: 0.273 * boardImageView.bounds.height,
                                         width: 0.922 * boardImageView.bounds.width,
                                         height: 0.703 * boardImageView.bounds.height))
        boardView.backgroundColor = Color.BoardBackground
        boardImageView.addSubview(boardView)
    }
    
    private func updateStepsLabel() {
        stepLabel.text = Text.Step_Chinese + " \(currentStep) / " + Text.Step_English + " \(currentStep)"
    }
    
    // adds the pieces on the board in the appropriate locations
    private func updateBoard() {
        // clear board
        boardView.subviews.forEach({ $0.removeFromSuperview() })
        // get board
        let board = boards[currentStep]
        // add pieces
        for piece in board.pieces {
            let pieceFrame = piece.getFrame(boardSize: (columns: options.boardColumns, rows: options.boardRows), boardBounds: boardView.bounds)
            let imageView = UIImageView(frame: pieceFrame)
            imageView.image = UIImage(named: piece.imageName)
            boardView.addSubview(imageView)
        }
    }
}

