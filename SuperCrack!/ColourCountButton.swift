//
//  ColourCountButton.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 27/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class ColourCountButton: UIButton {
  
  private var colCountIndex: Int
  
  func getColCountIndex() -> Int {
    return colCountIndex
  }
  
  required init(colourCountIndex: Int) {
    self.colCountIndex = colourCountIndex
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
