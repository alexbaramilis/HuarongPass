//
//  CustomPiece.swift
//  华容道
//
//  Created by Alexandros Baramilis on 01/03/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import UIKit

protocol CustomPieceDelegate: class {
    func didTap(piece: Piece, sender: CustomPiece)
}

/// A subclass of UIImageView used to display a piece on the custom board. It holds a reference to its associated Piece and passes it back when it's tapped, through the CustomPieceDelegate.
class CustomPiece: UIImageView {
    let associatedPiece: Piece
    
    weak var delegate: CustomPieceDelegate?
    
    init(frame: CGRect, associatedPiece: Piece, delegate: CustomPieceDelegate) {
        self.associatedPiece = associatedPiece
        self.delegate = delegate
        super.init(frame: frame)
        image = UIImage(named: associatedPiece.imageName)
        isUserInteractionEnabled = true // needed to handle taps
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTap() {
        delegate?.didTap(piece: associatedPiece, sender: self)
    }
}
