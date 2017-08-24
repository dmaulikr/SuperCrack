//
//  MemoryPegModel.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 11/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import Foundation


enum DesignatedState: Int {
  case maybe = 1, no, yes
  static var count: Int { return DesignatedState.yes.hashValue + 1}
}


class MemoryPeg: Peg {
  
  private var state: DesignatedState
  private var hidden: Bool

  override var description: String {
    return "Colour:\(getPegColour()) \t\tLocation:(\(column),\(row) and state: \(state))"
//    return "\(pegColour.pegLetter)"
  }
  
  override init(column: Int, row: Int, pegColour: PegColour) {
    self.state = DesignatedState.maybe
    self.hidden = false
    super.init(column: column, row: row, pegColour: pegColour)
    super.column = column
    super.row = row
    super.setPegColour(aPegColour: pegColour)
  }
  
  func setHidden(isHidden: Bool) {
    hidden = isHidden
  }
  
  func isHidden() -> Bool {
    return hidden
  }
  
  func setState(state: DesignatedState) {
    self.state = state
  }
  
  func getState() -> DesignatedState {
    return self.state
  }
}
