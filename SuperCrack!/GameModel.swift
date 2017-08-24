//
//  GameModel.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import Foundation

class GameModel {
  
  private var settings: Settings
  private var gameIsBeingPlayed: Bool
  private var gameIsWon: Bool
  private var turnNumber: Int
  private var numInCode: Int
  private var numGuesses: Int
  private var numColours: Int
  private var numRowsToUse: Int
  private var endSoundHasBeenPlayed: Bool
  private let defHole: Hole = Hole(holeType: HoleType.playableHole, column: 0, row: 0, staticPeg: nil, dynamicPeg: nil, isHidden: false, paletteColour: PegColour.noPeg)
  
  var boardHoles: [Hole] = Array()
  
  init() {
    settings = Settings()
    numInCode      = settings.getSettings()[0].getValue() // 4,5 or 6
    numColours     = settings.getSettings()[1].getValue() // 4, 5, 6, 7, 8
    numGuesses     = settings.getSettings()[2].getValue() // 8, 9, 10, 11 or 12. For UI, Guesses MUST be >= numColours
    numRowsToUse   = numGuesses+1 //Since we want to have the hidden code at the top
    //Init Game:
    gameIsBeingPlayed = true
    gameIsWon = false
    turnNumber = 1
    endSoundHasBeenPlayed = false
  }
  
  func initGame() {
    numInCode      = settings.getSettings()[0].getValue() // 4,5 or 6
    numColours     = settings.getSettings()[1].getValue() // 4, 5, 6, 7, 8
    numGuesses     = settings.getSettings()[2].getValue() // 8, 9, 10, 11 or 12. For UI, Guesses MUST be >= numColours
    numRowsToUse   = numGuesses+1 //Since we want to have the hidden code at the top
    gameIsBeingPlayed = true
    gameIsWon = false
    turnNumber = 1
    endSoundHasBeenPlayed = false
  }
  
  func setupGameModel(dimensions: GameDimensions) {
    boardHoles = Array(repeating: Hole(holeType: HoleType.voidHole, column: 0, row: numRowsToUse, staticPeg: nil, dynamicPeg: nil, isHidden: false, paletteColour: PegColour.noPeg), count: dimensions.boardCount)
    setupCodeAndHoles()
  }
  
  func setEndSoundBeenPlayed(played: Bool) {
    endSoundHasBeenPlayed = played
  }
  
  func hasEndSoundBeenPlayed() -> Bool {
    return endSoundHasBeenPlayed
  }
  
  func getBoardHoles() -> [Hole] {
    return boardHoles
  }
  
  func getNumInCode() -> Int {
    return numInCode
  }
  
  func setNumInCode(num: Int)  {
    numInCode = num
  }
  
  func getNumGuesses() -> Int {
    return numGuesses
  }
  
  func getNumColours() -> Int {
    return numColours
  }
  
  func getNumRowsToUse() -> Int {
    return numRowsToUse
  }
  
  func setNumRowsToUse(num: Int)  {
    numRowsToUse = num
  }
  
  func isGameWon() -> Bool {
    return gameIsWon
  }
  
  func isGameBeingPlayed() -> Bool {
    return gameIsBeingPlayed
  }
  
  func setGameBeingPlayed(played: Bool) {
    gameIsBeingPlayed = played
  }
  
  func getTurnNumber() -> Int {
    return turnNumber
  }
  
  func getSettings() -> Settings {
    return settings
  }

  func setupCodeAndHoles() {
    
    //Setup Code (hidden at the top of the Pegboard):
    
    for column in 1...numInCode { //Column starts at 1 because Column Zero is for the left palette pegs.  Therefore we WON'T use the boardHoles that represent the top left square (0,0) or those few beneath it.
      let pegColour = PegColour.random(numColours: numColours)
      let peg = Peg(column: column, row: numRowsToUse, pegColour: pegColour)
      let hole = Hole(holeType: HoleType.codeHole, column: column, row: numRowsToUse, staticPeg: peg, dynamicPeg: nil, isHidden: true, paletteColour: PegColour.noPeg)
      boardHoles[getSnapPointArrayIndexGivenColumnAndRow(col: column, row: numRowsToUse)] = hole
    }
    
    //Setup all other pegs:
    
    var pegColourIndex: Int = 1
    
    for row in (1..<numRowsToUse).reversed() {
      for column in 0...numInCode {
        
        var staticPeg: Peg?
        var dynamicPeg: Peg?
        
        var paletteColour: PegColour = PegColour(rawValue: 9)!
        var holeType: HoleType
        
        if row > numColours && column == 0 {
          //A void hole needs no pegs but must have proper location -> changed from (column: 0, row: GameSettings.numRowsToUse) to actual
          holeType = HoleType.voidHole
        }else{
          if column == 0  {
            holeType = HoleType.paletteHole
            paletteColour = PegColour(rawValue: pegColourIndex)!
            pegColourIndex = pegColourIndex + 1
          }else{
            holeType = HoleType.playableHole
          }
          staticPeg = Peg(column: column, row: row, pegColour: paletteColour)
          dynamicPeg = Peg(column: column, row: row, pegColour: paletteColour)
          dynamicPeg?.setDraggable(isDraggable: holeType == HoleType.paletteHole)   //At first, we only want the Palette Pegs to be moveable
        }
        let hole = Hole(holeType: holeType, column: column, row: row, staticPeg: staticPeg, dynamicPeg: dynamicPeg, isHidden: false, paletteColour: paletteColour)
        boardHoles[getSnapPointArrayIndexGivenColumnAndRow(col: column, row: row)] = hole
      }
    }
  }
  
  /*
   
   We'll fill our array so the top left (void) snappoint will be (0, numRowsToUse), so:
   
   (0, numRowsToUse) = index 0
   
   (1, numRowsToUse) = index 1
   
   ...
   
   (numInCode, 1) = index (array size -1)   [-1 since arrays start at 0]
   
   */
  
  func getSnapPointArrayIndexGivenColumnAndRow(col: Int, row: Int) -> Int {
    return col + (numRowsToUse - row) * (numInCode + 1)
  }
  
  func getHoleForPosition(column: Int, row: Int) -> Hole {
    let ret: Hole = defHole
    for hole in boardHoles {
      if hole.getColumn() == column && hole.getRow() == row {
        return hole
      }
    }
    return ret
  }
  
  func getHoleForPeg(peg: Peg) -> Hole {
    let ret: Hole = defHole
    for hole in boardHoles {
      if hole.getDynamicPeg() == peg || hole.getStaticPeg() == peg {
        return hole
      }
    }
    return ret
  }
  
  func getDraggedPeg() -> Peg {
    let ret: Peg = Peg(column: 0, row: 0, pegColour: PegColour.noPeg)
    for hole in boardHoles {
      //Has to be dynamic or we wouldn't be able to move it
      if let dynamicPeg = hole.getDynamicPeg() {
        if dynamicPeg.isBeingDragged() == true {
          return dynamicPeg
        }
      }
    }
    return ret
  }
  
  func getTurnPegs() -> [Peg] {
    var ret: [Peg] = Array()
    for i in 1...numInCode
    {
      let turnHole = boardHoles[getSnapPointArrayIndexGivenColumnAndRow(col: i, row: turnNumber)]
      if let turnPeg = turnHole.getDynamicPeg() {
        ret.append(turnPeg)
      }
    }
    return ret
  }
  
  func showCodeHoles() {
    for i in 1...numInCode
    {
      let codeHole = boardHoles[getSnapPointArrayIndexGivenColumnAndRow(col: i, row: numRowsToUse)]
      codeHole.setHidden(isHidden: false)
    }
  }
  
  private func getCodePegs() -> [Peg] {
    var ret: [Peg] = Array()
    for i in 1...numInCode
    {
      let codeHole = boardHoles[getSnapPointArrayIndexGivenColumnAndRow(col: i, row: numRowsToUse)]
      if let codePeg = codeHole.getStaticPeg() {
        if codeHole.getHoleType() == HoleType.codeHole {
          ret.append(codePeg)
        }
      }
    }
    return ret
  }
  
  func calculateFeedback() -> (posAndColCorrect: Int, colCorrect: Int) {
    
    var correctPosAndColour: Int = 0
    var correctColour: Int = 0
    var matchedTurnPegs: [Peg] = Array() //Store Pegs that feature in a match since they will only be in one match.
    
    //First match Pegs of correct colour and position:
    
    for i in 1...numInCode {
      if let codePeg = boardHoles[getSnapPointArrayIndexGivenColumnAndRow(col: i, row: numRowsToUse)].getStaticPeg(), let turnPeg = boardHoles[getSnapPointArrayIndexGivenColumnAndRow(col: i, row: turnNumber)].getDynamicPeg() {
        if codePeg.getPegColour() == turnPeg.getPegColour() {
          correctPosAndColour = correctPosAndColour + 1
          matchedTurnPegs.append(turnPeg)
          matchedTurnPegs.append(codePeg)
        }
      }
    }
    
    //Match Pegs of correct colour but incorrect position:
    
    for turnPeg in getTurnPegs() {
      for codePeg in getCodePegs() {
        
        if !matchedTurnPegs.contains(turnPeg) && !matchedTurnPegs.contains(codePeg) {
          
          if turnPeg.getPegColour() == codePeg.getPegColour() {
            correctColour = correctColour + 1
            //print("Colour Match: Peg \(turnPeg) \t\tmatches Peg \(codePeg)")
            matchedTurnPegs.append(turnPeg)
            matchedTurnPegs.append(codePeg)
          }
        }
      }
    }
    //print("\n")
    
    if correctPosAndColour == numInCode {
      gameIsWon = true
    }
    return (correctPosAndColour, correctColour)
  }
  
  func incrementTurn() {
    //Set the static Pegs on the current Turn to match the colour of their dynamic Pegs:
    for i in 1...numInCode
    {
      let codeHole = boardHoles[getSnapPointArrayIndexGivenColumnAndRow(col: i, row: turnNumber)]
      codeHole.getStaticPeg()?.setPegColour(newPegColour: (codeHole.getDynamicPeg()?.getPegColour())!)
    }
    turnNumber += 1
  }
  
  func getDynamicPegForPoint(column: Int, row: Int) -> Peg? {
    var ret: Peg?
    for hole in getBoardHoles() {
      if let dynamicPeg = hole.getDynamicPeg() {
        if dynamicPeg.getColumn() == column && dynamicPeg.getRow() == row {
          ret = dynamicPeg
        }
      }
    }
    return ret
  }
  
  func assessIfTurnCanBeTakenForRow() -> Bool {
    var eachPegInTurnHasAColour: Bool = true
    for peg in getTurnPegs() {
      if peg.getPegColour() == PegColour.noPeg {
        eachPegInTurnHasAColour = false
      }
    }
    return eachPegInTurnHasAColour
  }
  
}
