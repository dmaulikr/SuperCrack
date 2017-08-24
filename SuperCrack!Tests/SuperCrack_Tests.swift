//
//  SuperCrack_Tests.swift
//  SuperCrack!Tests
//
//  Created by Dave Chambers on 23/08/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import XCTest
@testable import SuperCrack_

class SuperCrack_Tests: XCTestCase {
  var gameUnderTest: GameModel!
  
  override func setUp() {
    super.setUp()
    gameUnderTest = GameModel()
    
    //Set num rows to use as 11 (10 + 1):
    gameUnderTest.setNumRowsToUse(num: 11)
    
    //Set numPegsAcross as 7 (numInCode + 1):
    gameUnderTest.setNumInCode(num: 6)

    let boardCount = (gameUnderTest.getNumInCode()+1) * gameUnderTest.getNumRowsToUse()
    
    gameUnderTest.boardHoles = Array(repeating: Hole(holeType: HoleType.voidHole, column: 0, row: gameUnderTest.getNumRowsToUse(), staticPeg: nil, dynamicPeg: nil, isHidden: false, paletteColour: PegColour.noPeg), count: boardCount)
    gameUnderTest.setupCodeAndHoles()
  }
  
  override func tearDown() {
    gameUnderTest = nil
    super.tearDown()
  }
  
  func testFeedback6BluesInTurnMatches6BluesInCode() {
    fillBoardHolesForCode(colourArrayForCode: [PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue])
    fillBoardHolesForTurn(colourArrayForTurn: [PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue])
    
    let (posAndColCorrect, _) = gameUnderTest.calculateFeedback()
    
    XCTAssertEqual(posAndColCorrect, 6, "Feedback computed is wrong for position and colour correct")
  }
  
  func testFeedback6OrangesInTurnFailsToMatch6BluesInCode() {
    fillBoardHolesForCode(colourArrayForCode: [PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue])
    fillBoardHolesForTurn(colourArrayForTurn: [PegColour.orange, PegColour.orange, PegColour.orange, PegColour.orange, PegColour.orange, PegColour.orange])

    let (posAndColCorrect, _) = gameUnderTest.calculateFeedback()
    
    XCTAssertEqual(posAndColCorrect, 0, "Feedback computed is wrong for position and colour correct")
  }
  
  func testFeedbackPosAndColCorrectPartially() {
    fillBoardHolesForCode(colourArrayForCode: [PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue, PegColour.blue])
    fillBoardHolesForTurn(colourArrayForTurn: [PegColour.orange, PegColour.blue, PegColour.blue, PegColour.orange, PegColour.orange, PegColour.orange])
    
    let (posAndColCorrect, _) = gameUnderTest.calculateFeedback()
    
    XCTAssertEqual(posAndColCorrect, 2, "Feedback computed is wrong for position and colour correct")
  }
  
  func testFeedbackRightColourWrongPlace() {
    fillBoardHolesForCode(colourArrayForCode: [PegColour.white, PegColour.blue, PegColour.white, PegColour.blue, PegColour.white, PegColour.blue])
    fillBoardHolesForTurn(colourArrayForTurn: [PegColour.blue, PegColour.white, PegColour.blue, PegColour.white, PegColour.blue, PegColour.white])
    
    let (posAndColCorrect, colCorrect) = gameUnderTest.calculateFeedback()
    
    XCTAssertEqual(posAndColCorrect, 0, "Feedback computed is wrong for position and colour correct")
    XCTAssertEqual(colCorrect, 6, "Feedback computed is wrong for colour correct")
  }
  
  func testFeedbackRightColourWrongPlace2() {
    fillBoardHolesForCode(colourArrayForCode: [PegColour.red, PegColour.orange, PegColour.yellow, PegColour.green, PegColour.purple, PegColour.blue])
    fillBoardHolesForTurn(colourArrayForTurn: [PegColour.blue, PegColour.red, PegColour.orange, PegColour.yellow, PegColour.green, PegColour.purple])
    
    let (posAndColCorrect, colCorrect) = gameUnderTest.calculateFeedback()
    
    XCTAssertEqual(posAndColCorrect, 0, "Feedback computed is wrong for position and colour correct")
    XCTAssertEqual(colCorrect, 6, "Feedback computed is wrong for colour correct")
  }
  
  func testFeedbackThatIsMixed() {
    fillBoardHolesForCode(colourArrayForCode: [PegColour.red, PegColour.orange, PegColour.yellow, PegColour.green, PegColour.purple, PegColour.blue])
    fillBoardHolesForTurn(colourArrayForTurn: [PegColour.blue, PegColour.orange, PegColour.yellow, PegColour.yellow, PegColour.green, PegColour.white])
    
    let (posAndColCorrect, colCorrect) = gameUnderTest.calculateFeedback()
    
    XCTAssertEqual(posAndColCorrect, 2, "Feedback computed is wrong for position and colour correct")
    XCTAssertEqual(colCorrect, 2, "Feedback computed is wrong for colour correct")
  }
  
  //MARK: Helper Functions:
  
  func fillBoardHolesForTurn(colourArrayForTurn: [PegColour]) {
    var colCount = 1
    for col in colourArrayForTurn {
      let peg = Peg(column: colCount, row: gameUnderTest.getTurnNumber(), pegColour: col)
      let hole = Hole(holeType: HoleType.playableHole, column: colCount, row: gameUnderTest.getTurnNumber(), staticPeg: nil, dynamicPeg: peg, isHidden: true, paletteColour: PegColour.noPeg)
      gameUnderTest.boardHoles[gameUnderTest.getSnapPointArrayIndexGivenColumnAndRow(col: colCount, row: gameUnderTest.getTurnNumber())] = hole
      colCount += 1
    }
  }
  
  func fillBoardHolesForCode(colourArrayForCode: [PegColour]) {
    var colCountForCode = 1
    for col in colourArrayForCode {
      let peg = Peg(column: colCountForCode, row: gameUnderTest.getNumRowsToUse(), pegColour: col)
      let hole = Hole(holeType: HoleType.codeHole, column: colCountForCode, row: gameUnderTest.getNumRowsToUse(), staticPeg: peg, dynamicPeg: nil, isHidden: true, paletteColour: PegColour.noPeg)
      gameUnderTest.boardHoles[colCountForCode] = hole
      colCountForCode += 1
    }
  }
  
}
