//
//  TurnView.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 19/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class TurnView: UIView {
  
  var pegs: [Peg]?
  
  override init(frame: CGRect){
    super.init(frame: frame)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }

  override var description: String {
    return "Pegs on this Turn: \(String(describing: pegs))"
  }

  
}
