//
//  PegModel.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import Foundation


enum PegColour: Int, CustomStringConvertible {
  case unknown = 0, red, orange, yellow, green, purple, blue, cyan, white, noPeg
  
  private var pegName: String {
    let pegNames = [
      "Red_Peg",
      "Orange_Peg",
      "Yellow_Peg",
      "Green_Peg",
      "Purple_Peg",
      "Blue_Peg",
      "Cyan_Peg",
      "White_Peg",
      "No_Peg"]
    
    return pegNames[rawValue - 1]
  }
  
  private var pegLetter: String {
    let pegLetters = [
      "R",
      "O",
      "Y",
      "G",
      "P",
      "B",
      "C",
      "W",
      "-"]
    
    return pegLetters[rawValue - 1]
  }
  
  var description: String {
    return getPegName()
  }
  
  func getPegName() -> String {
    return pegName
  }
  
  func getPegLetter() -> String {
    return pegLetter
  }
  
  static func random(numColours: Int) -> PegColour {
    return PegColour(rawValue: Int(arc4random_uniform(UInt32(numColours))) + 1)!
  }

  static func getColourLetter(index: Int) -> String {
    let temp: PegColour = PegColour(rawValue: index)!
    return temp.pegLetter
  }
}

class Peg: CustomStringConvertible, Hashable {
  
  var column: Int
  var row: Int
  private var pegColour: PegColour
  private var draggable: Bool
  private var beingDragged: Bool
  
  var description: String {
    return "Colour:\(pegColour) \t\tLocation:(\(column),\(row))"
//    return "\(pegColour.pegLetter)"
  }

  //To be used in a set, must be Hashable and that requires:
  internal var hashValue: Int {
    return row*10 + column
  }
  
  init(column: Int, row: Int, pegColour: PegColour) {
    self.column = column
    self.row = row
    self.pegColour = pegColour
    self.draggable = false
    self.beingDragged = false
  }
  
  func getColumn() -> Int {
    return column
  }
  
  func getRow() -> Int {
    return row
  }
  
  func getPegColour() -> PegColour {
    return pegColour
  }
  
  func setPegColour(aPegColour: PegColour) {
    pegColour = aPegColour
  }
  
  func setPegColour(newPegColour: PegColour) {
    pegColour = newPegColour
  }
  
  func isDraggable() -> Bool {
    return draggable
  }
  
  func setDraggable(isDraggable: Bool) {
    draggable = isDraggable
  }
  
  func isBeingDragged() -> Bool {
    return beingDragged
  }
  
  func setIsBeingDragged(isBeingDragged: Bool) {
    beingDragged = isBeingDragged
  }
  
}

//To be used in a set, must be Hashable and that requires:
func ==(lhs: Peg, rhs: Peg) -> Bool {
  return lhs.getColumn() == rhs.getColumn() && lhs.getRow() == rhs.getRow()
}
