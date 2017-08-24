//
//  MoveModel.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 05/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import Foundation


struct Move: CustomStringConvertible {
  private let pegA: Peg
  private let pegB: Peg
  
  init(pegA: Peg, pegB: Peg) {
    self.pegA = pegA
    self.pegB = pegB
  }
  
  var description: String {
    return "Moved \(pegA) to \(pegB)"
  }
}
