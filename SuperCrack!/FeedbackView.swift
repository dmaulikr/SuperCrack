//
//  FeedbackView.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 05/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class FeedbackView: UIView {
  
  private let dimensions: GameDimensions
  private var game: GameModel
  
  init(frame: CGRect, dimensions: GameDimensions, game:GameModel){
    self.dimensions = dimensions
    self.game = game
    super.init(frame: frame)
    setupView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  func setupView() {
    let increment = dimensions.tileSize-dimensions.pegPadding
    let division = increment/4
    
    /*
     
     An = sign is placed for each code peg from the guess which is correct in color and position.
     
     else, an ≈ sign is placed for each code peg from the guess which is correct in color.
     
     */
    
    let (posAndColCorrect, colCorrect) = game.calculateFeedback()
    
    let approx: UILabel = UILabel()
    approx.textAlignment = .center
    approx.backgroundColor = UIColor.clear
    approx.text = "≈" //approx equal to
    approx.font = UIFont.boldSystemFont(ofSize: dimensions.buttonFontSize*0.8)
    approx.textColor = UIColor.black
    approx.frame.size = CGSize(width: increment/2, height: increment/2)
    approx.center = CGPoint(x: division, y: division*0.8)
    self.addSubview(approx)
    
    let equals: UILabel = UILabel()
    equals.textAlignment = .center
    equals.backgroundColor = UIColor.clear
    equals.text = "=" //equal to
    equals.font = UIFont.boldSystemFont(ofSize: dimensions.buttonFontSize*0.8)
    equals.textColor = UIColor.black
    equals.frame.size = CGSize(width: increment/2, height: increment/2)
    equals.center = CGPoint(x: division, y: (division*0.8)+2*division)
    self.addSubview(equals)
    
    let colLabel: UILabel = UILabel()
    colLabel.textAlignment = .center
    colLabel.backgroundColor = UIColor.clear
    colLabel.text = String(colCorrect)
    colLabel.font = UIFont.boldSystemFont(ofSize: dimensions.buttonFontSize*0.8)
    colLabel.textColor = UIColor.black
    colLabel.frame.size = CGSize(width: increment/2, height: increment/2)
    colLabel.center = CGPoint(x: division+2*division, y: division)
    self.addSubview(colLabel)
    
    let posAndColLabel: UILabel = UILabel()
    posAndColLabel.textAlignment = .center
    posAndColLabel.backgroundColor = UIColor.clear
    posAndColLabel.text = String(posAndColCorrect)
    posAndColLabel.font = UIFont.boldSystemFont(ofSize: dimensions.buttonFontSize*0.8)
    posAndColLabel.textColor = UIColor.black
    posAndColLabel.frame.size = CGSize(width: increment/2, height: increment/2)
    posAndColLabel.center = CGPoint(x: division+2*division, y: division+2*division)
    self.addSubview(posAndColLabel)
    
  }
  
}
