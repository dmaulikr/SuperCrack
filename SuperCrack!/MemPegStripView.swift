//
//  MemPegStripView.swift
//  MastermindJune
//
//  Created by Dave Chambers on 27/06/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class MemPegStripView: UIView {
  
  private var memPegs: [MemoryPeg]
  private var column: Int
  
  func getCol() -> Int {
    return column
  }
  
  required init(memPegs: [MemoryPeg], col: Int) {
    self.memPegs = memPegs
    self.column = col
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func getPegs() -> [MemoryPeg] {
    return self.memPegs
  }
  
}
