//
//  ResetState.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 29/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit

/**
 Used to store the state of the MemoryView...
 */

class ResetState {
  
  var lastCloseRowButtonTapped: CloseRowButton
  var lastColourPairRemoved: (UIColor, UIColor)
  var pegColourRemovedFromIndex: Int
  var colCountValueRemovedIndex: Int
  var colCountValueRemoved: Int
  var statesOfRowWeRemoved: [DesignatedState] = Array()
  
  init(lastCloseRowButtonTapped: CloseRowButton
  , lastColourPairRemoved: (UIColor, UIColor)
  , pegColourRemovedFromIndex: Int
  , colCountValueRemovedIndex: Int
  , colCountValueRemoved: Int
  , statesOfRowWeRemoved: [DesignatedState]) {
    self.lastCloseRowButtonTapped = lastCloseRowButtonTapped
    self.lastColourPairRemoved = lastColourPairRemoved
    self.pegColourRemovedFromIndex = pegColourRemovedFromIndex
    self.colCountValueRemovedIndex = colCountValueRemovedIndex
    self.colCountValueRemoved = colCountValueRemoved
    self.statesOfRowWeRemoved = statesOfRowWeRemoved
  }

}

