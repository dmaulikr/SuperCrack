//
//  CloseRowButton.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 14/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit

class CloseRowButton: UIButton {
  
  private let pegsInRow: [MemoryPeg]
  
  func getPegsInRow() -> [MemoryPeg] {
    return pegsInRow
  }
  
  required init(pegsInRow: [MemoryPeg]) {
    self.pegsInRow = pegsInRow
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
