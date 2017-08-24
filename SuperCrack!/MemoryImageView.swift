//
//  MemoryImageView.swift
//  MastermindJune
//
//  Created by Dave Chambers on 27/06/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class MemoryImageView: UIImageView {
  
  private var memPeg: MemoryPeg
  
  required init(memPeg: MemoryPeg) {
    self.memPeg = memPeg
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func getPeg() -> MemoryPeg {
    return self.memPeg
  }
  
}
