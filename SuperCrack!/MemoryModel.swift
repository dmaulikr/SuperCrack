//
//  MemoryModel.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 11/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import Foundation


class MemoryModel {
  
  let gameModel: GameModel
  
  var colourCounts: [Int] = Array()
  var ruledOutColours: [PegColour]
  var numColoursToShow: Int
  var memPegs: [MemoryPeg] = Array()
  
  private var justTicks = false
  private var totalNumberOfStates: Int
  private var numStatesBasedOnAssumptions: Int
  
  func getTotalNumberOfStates() -> Int {
    return totalNumberOfStates
  }
  
  func getNumStatesBasedOnAssumptions() -> Int {
    return numStatesBasedOnAssumptions
  }
  
  func setNumStatesBasedOnAssumptions(num: Int) {
    numStatesBasedOnAssumptions = num
  }
  
  func getMemoryPegs() -> [MemoryPeg] {
    return memPegs
  }
  
  func getRowOfMemoryPegs(row: Int) -> [MemoryPeg] {
    return memPegs.filter { $0.getRow() == row }
  }
  
  func getColumnOfMemoryPegs(col: Int) -> [MemoryPeg] {
    return memPegs.filter { $0.column == col }
  }
  
  func getColumnOfMemoryPegsNotCrossedInUI(col: Int) -> [MemoryPeg] {
    return memPegs.filter { $0.column == col && $0.getState() != DesignatedState.no}
  }
  
  func getColumnOfMemoryPegsCrossedInUILessThanRow(col: Int, row: Int) -> [MemoryPeg] {
    return memPegs.filter { $0.column == col && $0.getRow() < row && $0.getState() == DesignatedState.no}
  }
  
  func getPegsWhereOneInThatColumnHasATick() -> [MemoryPeg] {
    
    var colHasTick: [Int] = Array()
    for peg in memPegs {
      if peg.getState() == DesignatedState.yes && !colHasTick.contains(peg.column) {
        colHasTick.append(peg.column)
      }
    }
    var ret: [MemoryPeg] = Array()
    for colWithTick in colHasTick {
      ret += getColumnOfMemoryPegs(col: colWithTick)
    }
    return ret
    
  }
  
  func isThereATickInColumn(col: Int) -> Bool {
    var ret = false
    for peg in memPegs {
      if peg.getState() == DesignatedState.yes && peg.column == col {
        ret = true
      }
    }
    return ret
    
  }
  
  func doesEachSlotHaveAColour() -> Bool {
    let ret = true
    for col in 1...self.gameModel.getNumInCode() {
      if getColumnOfMemoryPegsNotCrossedInUI(col: col).count == 0 {
        return false
      }
    }
    return ret
  }
  
  init(gameModel: GameModel) {
    
    self.gameModel = gameModel
    
    /*
 
     With four pegs and six colors, there are 6^4 = 1296 different patterns (allowing duplicate colors). (Wikipedia) --> this is right

     */
        
    totalNumberOfStates = Int(NSDecimalNumber(decimal: pow(Decimal(gameModel.getNumColours()), gameModel.getNumInCode())))
    numStatesBasedOnAssumptions = totalNumberOfStates //at start
    for col in 1...gameModel.getNumInCode() { //Column starts at 1 because Column Zero is for the left palette pegs.  Therefore we WON'T use the baordHoles that represent the top left square (0,0) or those few beneath it.
      for row in 1...gameModel.getNumColours() {
        let memPeg = MemoryPeg(column: col, row: row, pegColour: PegColour(rawValue: row)!)
        //print("Peg Colour: \(memPeg)")
        memPegs.append(memPeg)
      }
    }
    for _ in 1...gameModel.getNumColours() {
      colourCounts.append(0)
    }
    numColoursToShow = gameModel.getNumColours()
    ruledOutColours = Array()
  }
  
  func reinit(gameModel: GameModel) {
    
    memPegs.removeAll()
    
    totalNumberOfStates = Int(NSDecimalNumber(decimal: pow(Decimal(gameModel.getNumColours()), gameModel.getNumInCode())))
    numStatesBasedOnAssumptions = totalNumberOfStates //at start
    for col in 1...gameModel.getNumInCode() { //Column starts at 1 because Column Zero is for the left palette pegs.  Therefore we WON'T use the baordHoles that represent the top left square (0,0) or those few beneath it.
      for row in 1...gameModel.getNumColours() {
        let memPeg = MemoryPeg(column: col, row: row, pegColour: PegColour(rawValue: row)!)
        //print("Peg Colour: \(memPeg)")
        memPegs.append(memPeg)
      }
    }
    for _ in 1...gameModel.getNumColours() {
      colourCounts.append(0)
    }
    numColoursToShow = gameModel.getNumColours()
  }
}
