//
//  HoleModel.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import Foundation

enum HoleType: Int, CustomStringConvertible {
  case unknown = 0, codeHole, paletteHole, playableHole, voidHole
  
  private var holeType: String {
    let holeTypes = [
      "Code_Hole",
      "Palette_Hole",
      "Playable_Hole",
      "Void_Hole"]
    
    return holeTypes[rawValue - 1]
  }
  
  var description: String {
    return holeType
  }
  
}


class Hole: CustomStringConvertible {
  private var holeType:       HoleType
  private var column:         Int
  private var row:            Int
  private var hidden:         Bool
  private var staticPeg:      Peg?        //Can NOT move - just to colour the Hole
  private var dynamicPeg:     Peg?        //Can be dragged
  private var paletteColour:  PegColour?  //Remove?
    
  var description: String {
    return "Type of Hole: \(holeType). \t\tStatic Peg in the hole: \(String(describing: staticPeg)) \t\tDynamic Peg in the hole: \(String(describing: dynamicPeg)). \tHole Location:(\(column),\(row))"
  }
  
  init(holeType: HoleType, column: Int, row: Int, staticPeg: Peg?, dynamicPeg: Peg?, isHidden: Bool, paletteColour: PegColour) {
    self.holeType = holeType
    self.column = column
    self.row = row
    self.staticPeg = staticPeg
    self.dynamicPeg = dynamicPeg
    self.hidden = isHidden
    self.paletteColour = paletteColour
  }
  
  func getHoleType() -> HoleType {
    return holeType
  }
  
  func getColumn() -> Int {
    return column
  }
  
  func getRow() -> Int {
    return row
  }
  
  func isHidden() -> Bool {
    return hidden
  }
  
  func setHidden(isHidden: Bool) {
    hidden = isHidden
  }
  
  func getStaticPeg() -> Peg? {
    return staticPeg
  }
  
  func getDynamicPeg() -> Peg? {
    return dynamicPeg
  }
  
  func getPegPair() -> (staticPeg: Peg?, dynamicPeg: Peg?) {
    return (staticPeg, dynamicPeg)
  }
  
  func getPaletteColour() -> PegColour? {
    return paletteColour
  }
  
}
