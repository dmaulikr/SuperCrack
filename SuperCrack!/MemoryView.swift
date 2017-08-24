//
//  MemoryView.swift
//  MastermindJune
//
//  Created by Dave Chambers on 23/06/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import SwiftySound
import UIKit
import Crashlytics

let tick = "\u{2713}"
let cross = "\u{2717}"

class MemoryView: UIView, UIScrollViewDelegate {
  
  private let dimensions:   GameDimensions
  private let game:         GameModel
  private var memoryModel:  MemoryModel
  
  private let showOnlyTicksButton = ShowOnlyTicksButton()
  private let turnsScrollView = UIScrollView()
  private let pegBoardImageView :UIImageView = UIImageView()
  private var arrayOfResetStates: [ResetState] = Array()
  private var infoViews: [UITextField]
  private var turns: [TurnView]
  private var pegColours: ArraySlice<(UIColor, UIColor)>!
  private var pegboardWindow = UIScrollView()
  private var memPegStripViews: [MemPegStripView] = Array()
  private var memPegStripScrollViews: [UIScrollView] = Array()
  private var pegBoardSnapshot: UIImage
  private let initialNumRowsVisibleInTopScrollView: Int //Always will show n rows in the scrollview TO START WITH.  Since this will chnage can I do a const expression in C++ or calculated thingy in Swift???
  private var numRowsVisibleInTopScrollView: Int
  private var bottomSection: UIView = UIView()
  
  private var pegBoardImageBottom:              CGFloat = 0
  private var buttonHeight:                     CGFloat = 0
  private var gapHeight:                        CGFloat = 0
  private var centreYOfIndividualScrollviews:   CGFloat = 0
  private var centreYOfScenesScrollviews:       CGFloat = 0
  private var insetOfTurnsScrollview:           CGFloat = 0
  private var spaceForButtons:                  CGFloat = 0
  
  func setSnapshot(snap: UIImage) {
    pegBoardSnapshot = snap
  }
  
  func getPegBoardImageView() -> UIImageView {
    return pegBoardImageView
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  init(frame: CGRect, game: GameModel, memModel: MemoryModel, dimensions: GameDimensions, pegBoard: UIImage){
    self.game = game
    self.memoryModel = memModel
    self.pegBoardSnapshot = pegBoard
    self.dimensions = dimensions
    
    let value: Int
    
    //Calculate initial Num Rows Visible In Top ScrollView....
    
    switch memoryModel.numColoursToShow {
    case 4:
      
      switch game.getNumGuesses() {
      case 8:
        value = 3
      case 9:
        value = 4
      case 10:
        value = 5
      case 11:
        value = 5
      case 12:
        value = 5
      default:
        value = 3
      }
    case 5:
      
      switch game.getNumGuesses() {
      case 8:
        value = 2
      case 9:
        value = 3
      case 10:
        value = 3
      case 11:
        value = 4
      case 12:
        value = 4
      default:
        value = 2
      }
    case 6:
      
      switch game.getNumGuesses() {
      case 8:
        value = 2
      case 9:
        value = 2
      case 10:
        value = 3
      case 11:
        value = 3
      case 12:
        value = 3
      default:
        value = 2
      }
    case 7:
      
      switch game.getNumGuesses() {
      case 8:
        value = 1
      case 9:
        value = 1
      case 10:
        value = 2
      case 11:
        value = 2
      case 12:
        value = 2
      default:
        value = 1
      }
    case 8:
      
      switch game.getNumGuesses() {
      case 8:
        value = 1
      case 9:
        value = 1
      case 10:
        value = 2
      case 11:
        value = 2
      case 12:
        value = 2
      default:
        value = 1
      }
      
    default:
      value = 1
    }
    
    self.initialNumRowsVisibleInTopScrollView = value
    self.numRowsVisibleInTopScrollView = value
    infoViews = Array()
    turns = Array()
    super.init(frame: frame)
    setupUI()

  }

  func setupUI() {
    let allColours = [(UIColor.red, UIColor.white), (UIColor.orangePeg, UIColor.black), (UIColor.yellow, UIColor.black), (UIColor.greenPeg, UIColor.white), (UIColor.purplePeg, UIColor.white), (UIColor.bluePeg, UIColor.white), (UIColor.cyan, UIColor.black), (UIColor.white, UIColor.black),(UIColor.black, UIColor.white)]
    //Reduce our colour set to those we are playing with this game...
    self.pegColours = allColours[0..<game.getNumColours()]
    //Layout of bottom section won't change
    setupBottomControlSection()
    //Image of PegBoard:
    setupTopWindowToPegboard()
    setupDynamicArea()
    setupInfoView()
  }
  
  func setupInfoView() {
    infoViews.removeAll()
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = NumberFormatter.Style.decimal
    setupInfoQuarter(gridCol: 0, gridRow: 0, text: "Assumed: \(numberFormatter.string(from: NSNumber(value:memoryModel.getNumStatesBasedOnAssumptions()))!)")
    setupInfoQuarter(gridCol: 0, gridRow: 1, text: "Possible: \(numberFormatter.string(from: NSNumber(value:memoryModel.getTotalNumberOfStates()))!)")
  }
  
  func setupInfoQuarter(gridCol: Int, gridRow: Int, text: String) {
    let infoView: UITextField = UITextField();
    infoView.isUserInteractionEnabled = false
    infoView.textAlignment = NSTextAlignment.center
    infoView.text = text
    infoView.borderStyle = UITextBorderStyle.line
    infoView.layer.borderColor = UIColor.white.cgColor
    infoView.layer.borderWidth = 2.0
    infoView.backgroundColor = UIColor.black
    infoView.textColor = UIColor.white
    infoView.font = UIFont.systemFont(ofSize: CGFloat(dimensions.buttonFontSize/3))
    self.addSubview(infoView)
    infoViews.append(infoView)
    infoView.snp.makeConstraints { (make) -> Void in
      let height = (dimensions.pegSize-dimensions.pegPadding)/2
      make.height.equalTo(height)
      let width = self.center.x-insetOfTurnsScrollview
      make.width.equalTo(width)
      make.centerX.equalTo(self.center.x)
      let additionalCentre: CGFloat = gridRow == 0 ? -0.5 : 0.5
      make.centerY.equalTo(dimensions.usableHeight-0.5*dimensions.pegSize+additionalCentre*height)
    }
  }
  
  func setupDynamicArea() {
    calculateSpaceForButtons()
    setupCrossButtons()
  }
  
  func setupBottomControlSection() {
    bottomSection = UIView(frame: CGRect(x: 0, y: dimensions.usableHeight-3*dimensions.pegSize, width: self.frame.width, height: 3*dimensions.pegSize+dimensions.tabBarHeight)) //We use 3.1 instead of 3 because we want a little gap above the provisional scrollviews
    addSubview(bottomSection)
    bottomSection.backgroundColor = UIColor.black
    setupProvisionalSlots() //Do this first since we need to know some UI measurements from here for the turnsScrollView
    
    //Scene View:
    turnsScrollView.isPagingEnabled = true
    self.addSubview(turnsScrollView)
    turnsScrollView.backgroundColor = UIColor.black
    turnsScrollView.snp.makeConstraints { (make) -> Void in
      make.height.equalTo(dimensions.pegSize)
      make.left.equalTo(insetOfTurnsScrollview)
      make.width.equalTo((self.center.x-insetOfTurnsScrollview)*2)
      make.centerY.equalTo(dimensions.usableHeight-1.5*dimensions.pegSize)
    }
    
    //Left Side Buttons:
    setupControlButton(col: 0, row: 3, resourceName: "ToPegboard", selector: #selector(toPegboardFromProvisionalView))
    setupControlButton(col: 0, row: 2, resourceName: "ToPegboard", selector: #selector(toPegboardFromTurnsSelection))
    setupControlButton(col: 0, row: 1, resourceName: "Undo", selector: #selector(undoLastCrossedOffRow))
    
    //Right Side Buttons:
    setupControlButton(col: game.getNumInCode()+1, row: 3, resourceName: "CaptureAndInsert", selector: #selector(captureAndInsertTurn))
    setupControlButton(col: game.getNumInCode()+1, row: 2, resourceName: "RemoveTurn", selector: #selector(removeTurn))
    setupControlButton(col: game.getNumInCode()+1, row: 1, resourceName: "Reset", selector: #selector(resetAll))
    
    setupButtonGridShowsOnlyTicks()
    setupButtonGridTurnQstoCrosses()
  }
  
  func setupButtonGridShowsOnlyTicks() {
    let image = UIImage(named: "ShowOnlyTicks")
    showOnlyTicksButton.setImage(image, for: UIControlState.normal)
    showOnlyTicksButton.layer.borderWidth = 1.0
    showOnlyTicksButton.layer.borderColor = UIColor.white.cgColor
    showOnlyTicksButton.addTarget(self, action: #selector(showOnlyTicks), for: UIControlEvents.touchUpInside)
    self.addSubview(showOnlyTicksButton)
    showOnlyTicksButton.snp.makeConstraints { (make) -> Void in
      make.width.height.equalTo(dimensions.pegSize-dimensions.pegPadding)
      let point: CGPoint = UIHelpers.pointFor(column: 1, row: 1, dimensions: dimensions)
      make.centerX.equalTo(point.x)
      make.centerY.equalTo(dimensions.usableHeight-(CGFloat(1)-0.5)*dimensions.pegSize)
    }
  }
  
  func showOnlyTicks(sender: ShowOnlyTicksButton!) {
    if sender.isShowingOnlyTicks() {
      _ = memoryModel.getMemoryPegs().map{$0.setHidden(isHidden: false)}
    }else{
      let pegsInCol = memoryModel.getPegsWhereOneInThatColumnHasATick()
      for peg in pegsInCol {
        if peg.getState() != DesignatedState.yes {
          peg.setHidden(isHidden: !sender.isShowingOnlyTicks())
        }else{
          peg.setHidden(isHidden: sender.isShowingOnlyTicks())
        }
      }
    }
    sender.setImage(sender.isShowingOnlyTicks() ? UIImage(named: "ShowOnlyTicks") : UIImage(named: "ShowAllSymbols"), for: .normal)
    sender.setShowingOnlyTicks(showingOnly: !sender.isShowingOnlyTicks())
    self.setNeedsLayout()
  }
  
  func updateAccordingToShowOnlyTicks() {
    if showOnlyTicksButton.isShowingOnlyTicks() {
      let pegsInCol = memoryModel.getPegsWhereOneInThatColumnHasATick()
      for peg in pegsInCol {
        if peg.getState() != DesignatedState.yes {
          peg.setHidden(isHidden: showOnlyTicksButton.isShowingOnlyTicks())
        }else{
          peg.setHidden(isHidden: !showOnlyTicksButton.isShowingOnlyTicks())
        }
      }
      //All those columns that now don't have a tick should have every button showing:
      _ = memoryModel.memPegs.filter{!pegsInCol.contains($0)}.map{$0.setHidden(isHidden: false)}
    }
    self.setNeedsLayout()
  }
  
  func setupButtonGridTurnQstoCrosses() {
    let btn = UIButton()
    let image = UIImage(named: "QuestionMarksToCrosses")
    btn.setImage(image, for: UIControlState.normal)
    btn.layer.borderWidth = 1.0
    btn.layer.borderColor = UIColor.white.cgColor
    btn.addTarget(self, action: #selector(turnQstoCrossesInColumnsWithTicks), for: UIControlEvents.touchUpInside)
    self.addSubview(btn)
    btn.snp.makeConstraints { (make) -> Void in
      make.width.height.equalTo(dimensions.pegSize-dimensions.pegPadding)
      let point: CGPoint = UIHelpers.pointFor(column: game.getNumInCode(), row: 1, dimensions: dimensions)
      make.centerX.equalTo(point.x)
      make.centerY.equalTo(dimensions.usableHeight-(CGFloat(1)-0.5)*dimensions.pegSize)
    }
  }
  
  func turnQstoCrossesInColumnsWithTicks() {
    for column in 1...game.getNumInCode() {
      let colOfPegs = memoryModel.getColumnOfMemoryPegs(col: column)
      var processThisColumn = false
      for pegInCol in colOfPegs {
        if pegInCol.getState() == DesignatedState.yes {
          processThisColumn = true
        }
      }
      if processThisColumn == true {
        for peg in colOfPegs {
          if peg.getState() == DesignatedState.maybe {
            peg.setState(state: DesignatedState.no)
            removeImageViewFromStripUsingMemoryPeg(memPeg: peg)
            memoryModel.ruledOutColours.append(peg.getPegColour())
          }
        }
      }
    }
    self.setNeedsLayout()
    writeAssumedNumber()
  }
  
  func setupProvisionalSlots() {
    _ = memPegStripViews.map{$0.removeFromSuperview()}
    _ = memPegStripScrollViews.map{$0.removeFromSuperview()}
    memPegStripViews.removeAll()
    memPegStripScrollViews.removeAll()
    
    for col in 1...game.getNumInCode() {
      
      //Single Selecting View:
      
      let scrollView = UIScrollView()
      scrollView.isPagingEnabled = true
      scrollView.delegate = (self as UIScrollViewDelegate)
      self.addSubview(scrollView)
      scrollView.backgroundColor = UIColor.black
 
      let point: CGPoint = UIHelpers.pointFor(column: col, row: 2, dimensions: dimensions)
 
      scrollView.snp.makeConstraints { (make) -> Void in
        make.width.height.equalTo(dimensions.pegSize)
        make.centerX.equalTo(point.x)
        make.centerY.equalTo(dimensions.usableHeight-2.5*dimensions.pegSize)
      }

      if col == 1 {
        insetOfTurnsScrollview = point.x - 0.5 * (dimensions.pegSize)
      }
      memPegStripScrollViews.append(scrollView)
      setupStripOfPegsForColumn(col: col, scrollToMemoryPeg: nil)
    }

  }
  
  func setupControlButton(col: Int, row: Int, resourceName: String, selector: Selector) {
    let controlButton = UIButton(type: UIButtonType.custom) as UIButton
    let image = UIImage(named: resourceName)
    controlButton.setImage(image, for: UIControlState.normal)
    controlButton.addTarget(self, action: selector, for: .touchUpInside)
    self.addSubview(controlButton)
    controlButton.snp.makeConstraints { (make) -> Void in
      make.width.height.equalTo(dimensions.pegSize-dimensions.pegPadding)
      let point: CGPoint = UIHelpers.pointFor(column: col, row: row, dimensions: dimensions)
      make.centerX.equalTo(point.x)
      make.centerY.equalTo(dimensions.usableHeight-(CGFloat(row)-0.5)*dimensions.pegSize)
    }
    
  }
  
  func setupTopWindowToPegboard() {
    self.addSubview(pegboardWindow)
    pegboardWindow.backgroundColor = UIColor.black
    pegboardWindow.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(0)
      make.width.equalTo(self.frame.width)
      pegBoardImageBottom = distBetweenTwoPoints()*CGFloat(numRowsVisibleInTopScrollView)
      make.height.equalTo(pegBoardImageBottom)
    }
    pegboardWindow.backgroundColor = UIColor.black
    
    //Adjust the scrollview contentsize and then the imageview height...
    let overSize = pegBoardSnapshot.size.width / self.frame.width
    let properHeight = pegBoardSnapshot.size.height/overSize
    pegboardWindow.contentSize = CGSize(width: self.frame.width, height: properHeight)
    pegBoardImageView.image = pegBoardSnapshot
    pegboardWindow.addSubview(pegBoardImageView)
    pegBoardImageView.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(self.frame.width)
      make.height.equalTo(properHeight)
      make.top.equalTo(pegBoardImageView.frame.origin.y)
    }
  }
  
  func distBetweenTwoPoints() -> CGFloat {
    let pointInRow2: CGPoint = UIHelpers.pointFor(column: 0, row: 2, dimensions: dimensions)
    let pointInRow1: CGPoint = UIHelpers.pointFor(column: 0, row: 1, dimensions: dimensions)
    return pointInRow1.y-pointInRow2.y
  }
  
  func calculateSpaceForButtons() {
    spaceForButtons = bottomSection.frame.origin.y - pegBoardImageBottom
    
    /*
     
     We want these buttons to take up all the space between top window to Pegboard and bottom controls = spaceForButtons
     
     If we have n buttons (equal to the memoryModel.numColoursToShow), then we need m = n+1 gaps.
     
     We want the vertical gaps between each button to be about r times smaller than the button.
     
     */
    let r: CGFloat = 4
    let numDivisions: CGFloat = r*CGFloat(memoryModel.numColoursToShow) + CGFloat(memoryModel.numColoursToShow+1)
    buttonHeight = r*spaceForButtons/numDivisions
    gapHeight = buttonHeight/r
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    //Remove all the views placed in previous calls to this method:
    _ = self.subviews.filter{$0 is MemoryButton || $0 is ColourCountButton}.map{$0.removeFromSuperview()}
    for (_, memPeg) in memoryModel.memPegs.enumerated() {
      if memoryModel.numColoursToShow > 0 {
        setupMemoryButton(memPeg: memPeg)
      }
    }
    if memoryModel.numColoursToShow > 0 {
      for row in (1...memoryModel.colourCounts.count) {
        setupColourCountButton(row: row, col: game.getNumInCode()+1)
      }
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.x = 0.0
    // If there is only one colour on that spot, sender.contentOffset.y = 0.0 --> not sure if this works
    if scrollView.contentSize.height <= dimensions.pegSize {
      scrollView.contentOffset.y = 0.0
    }
  }
  
  func setupColourCountButton(row: Int, col: Int) {
    let btn = ColourCountButton(colourCountIndex: row-1)
    btn.setTitle(String(memoryModel.colourCounts[row-1]), for: .normal)
    btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: dimensions.buttonFontSize)
    btn.layer.borderWidth = 1.0
    let (main, text) = self.pegColours[row-1]
    btn.backgroundColor = main
    btn.setTitleColor(text, for: UIControlState.normal)
    btn.layer.borderColor = UIColor.white.cgColor
    btn.addTarget(self, action: #selector(incrementColourCount), for: UIControlEvents.touchUpInside)
    self.addSubview(btn)
    btn.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(dimensions.pegSize)
      make.height.equalTo(buttonHeight)
      let point: CGPoint = UIHelpers.pointFor(column: col, row: row, dimensions: dimensions)
      make.centerX.equalTo(point.x)
      make.top.equalTo(pegBoardImageBottom+CGFloat(row)*gapHeight+CGFloat(row-1)*buttonHeight)
    }

  }
  
  func incrementColourCount(sender: ColourCountButton!) {
    var currentNumber: Int = memoryModel.colourCounts[sender.getColCountIndex()]
    //Increment the currentNumber
    currentNumber += 1
    if currentNumber > game.getNumColours() {
      currentNumber = 0
    }
    memoryModel.colourCounts[sender.getColCountIndex()] = currentNumber
    sender.setTitle(String(describing: currentNumber), for: .normal)
  }
  
  func setupCrossButton(row: Int, col: Int, title: String, sizeMultiplier: CGFloat) {
    //Send the Peg to the method so we know it's colour
    let pegsInRow = memoryModel.getRowOfMemoryPegs(row: row)
    let funcButton = CloseRowButton(pegsInRow: pegsInRow)
    self.addSubview(funcButton)
    funcButton.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(dimensions.pegSize)
      make.height.equalTo(buttonHeight)
      let point: CGPoint = UIHelpers.pointFor(column: col, row: row, dimensions: dimensions)
      make.centerX.equalTo(point.x)
      make.top.equalTo(pegBoardImageBottom+CGFloat(row)*gapHeight+CGFloat(row-1)*buttonHeight)
    }
    funcButton.backgroundColor = UIColor.white
    funcButton.setTitle(title, for: .normal)
    funcButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: dimensions.buttonFontSize*sizeMultiplier)
    funcButton.setTitleColor(UIColor.black, for: UIControlState.normal)
    funcButton.addTarget(self, action: #selector(closeRowButtonTapped), for: .touchUpInside)
    
  }
  
  func closeRowButtonTapped(sender: CloseRowButton!) {
    let pegsInRow = sender.getPegsInRow()
    _ = pegsInRow.filter{!memoryModel.ruledOutColours.contains($0.getPegColour())}.map{memoryModel.ruledOutColours.append($0.getPegColour())}
    var statesOfRowWeRemoved: [DesignatedState] = Array()
    for peg in pegsInRow {
      statesOfRowWeRemoved.append(peg.getState())
      peg.setState(state: DesignatedState.no) //Remove this colour from the Provisional scrollviews since it's had it's corresponding row crossed off
      removeImageViewFromStripUsingMemoryPeg(memPeg: peg)
    }
    //Removing row from memory model:
    let rowIndexWeAreRemoving = pegsInRow[0].getRow()
    let rowToRemove = memoryModel.getRowOfMemoryPegs(row: rowIndexWeAreRemoving)
    memoryModel.memPegs = memoryModel.memPegs.filter({!rowToRemove.contains($0)})
    //When we remove peg, decrement the NEXT colours ROW
    _ = memoryModel.getMemoryPegs().filter{$0.getRow() > rowIndexWeAreRemoving}.map{$0.row -= 1}

    //One time remove the colour from the array, storing it in case of undo:
    let pegColourRemovedFromIndex = pegsInRow[0].row-1
    let lastColourPairRemoved = self.pegColours[pegColourRemovedFromIndex]
    self.pegColours.remove(at: pegColourRemovedFromIndex)
    
    //Remove from colourCounts
    let colCountValueRemovedIndex = pegsInRow[0].row-1
    let colCountValueRemoved = memoryModel.colourCounts[colCountValueRemovedIndex]
    memoryModel.colourCounts.remove(at: colCountValueRemovedIndex)
    memoryModel.numColoursToShow -= 1
    pegboardWindow.snp.removeConstraints()
    pegboardWindow.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(0)
      make.width.equalTo(self.frame.width)
      pegBoardImageBottom += gapHeight + buttonHeight
      make.height.equalTo(pegBoardImageBottom)
    }
    setupDynamicArea()
    writeAssumedNumber()
    let lastCloseRowButtonTapped = sender
    let resetState = ResetState(lastCloseRowButtonTapped: lastCloseRowButtonTapped!
      , lastColourPairRemoved: lastColourPairRemoved
      , pegColourRemovedFromIndex: pegColourRemovedFromIndex
      , colCountValueRemovedIndex: colCountValueRemovedIndex
      , colCountValueRemoved: colCountValueRemoved
      , statesOfRowWeRemoved: statesOfRowWeRemoved)
    arrayOfResetStates.append(resetState)
    
  }
  
  func undoCloseRowButtonTapped(lastResetState: ResetState) {
    let pegsInRow = lastResetState.lastCloseRowButtonTapped.getPegsInRow()
    //Soon, we will put the members of pegsInRow back into memPegs BUT, first we must reset the row number if necessary:
    _ = memoryModel.memPegs.filter{$0.row >= pegsInRow[0].row}.map{$0.row += 1} //Increment the row to 'insert' the undone row again
    //Restore the assumed colours....
    memoryModel.memPegs += pegsInRow
    memoryModel.memPegs = memoryModel.memPegs.sorted(by: { $0.column == $1.column ? $0.row < $1.row : $0.column < $1.column }) //sort by column then by row
    for (index, element) in pegsInRow.enumerated() { //restore the mem button's state....
      element.setState(state: lastResetState.statesOfRowWeRemoved[index])
      setupStripOfPegsForColumn(col: element.column, scrollToMemoryPeg: nil)
    }
    //Restore the colour to the array:
    self.pegColours.insert(lastResetState.lastColourPairRemoved, at: lastResetState.pegColourRemovedFromIndex)
    //Restore the colourCounts
    memoryModel.colourCounts.insert(lastResetState.colCountValueRemoved, at: lastResetState.colCountValueRemovedIndex)
    memoryModel.numColoursToShow += 1
    pegboardWindow.snp.removeConstraints()
    pegboardWindow.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(0)
      make.width.equalTo(self.frame.width)
      pegBoardImageBottom -= gapHeight + buttonHeight
      make.height.equalTo(pegBoardImageBottom)
    }
    setupDynamicArea()
    writeAssumedNumber()
  }

  func captureAndInsertTurn() {
    let numberOfTurns = turnsScrollView.subviews.filter({$0.tag == 1}).count
    if memoryModel.doesEachSlotHaveAColour() {
      var pegsForTurn: [Peg] = Array()
      let turn = TurnView(frame: CGRect(x: 0, y: 0+CGFloat(numberOfTurns)*(dimensions.pegSize), width: (self.center.x-insetOfTurnsScrollview)*2, height: dimensions.pegSize))
      turn.backgroundColor = UIColor.black
      turn.tag = 1 //needed to identify a turn
      //Get the page of the scrollview for each position:
      for col in 1...game.getNumInCode() {
        let page = getPageForScrollview(scrollview: memPegStripScrollViews[col-1])
        //The Peg visible in the window:
        let pegInWindow = memoryModel.getColumnOfMemoryPegsNotCrossedInUI(col: col)[page]
        //Add the Peg to the provisionalTurn:
        pegsForTurn.append(pegInWindow)
        let imgView = addMemoryPeg(memPeg: pegInWindow)
        turn.addSubview(imgView)
        imgView.snp.makeConstraints { (make) -> Void in
          make.width.height.equalTo(dimensions.pegSize)
          let point: CGPoint = UIHelpers.pointFor(column: col, row: 1, dimensions: dimensions)
          make.centerX.equalTo(point.x-turnsScrollView.frame.origin.x)
          make.top.equalTo(0)
        }
      }
      turn.pegs = pegsForTurn
      var provisionalExistsInTurnsAlready = false
      for existingTurn in turns {
        var allColoursMatch = true
        for x in 0..<game.getNumInCode() {
          if existingTurn.pegs?[x].getPegColour() != turn.pegs?[x].getPegColour() {
            allColoursMatch = false
          }
        }
        if allColoursMatch == true {
          provisionalExistsInTurnsAlready = true
          break
        }
      }
      if provisionalExistsInTurnsAlready == false {
        turnsScrollView.delegate = (self as UIScrollViewDelegate)
        turnsScrollView.addSubview(turn)
        turnsScrollView.backgroundColor = UIColor.black
        turnsScrollView.contentSize = CGSize(width: turn.frame.width, height: CGFloat(numberOfTurns+1)*(dimensions.pegSize))
        //Scroll to see our added Turn
        let bottomOffset = CGPoint(x: 0, y: turnsScrollView.contentSize.height - turnsScrollView.bounds.size.height)
        turnsScrollView.setContentOffset(bottomOffset, animated: true)
        turns.append(turn)
      }else{
        Sound.play(file: "Error.wav")
      }
    }else{
      Sound.play(file: "Error.wav")
    }

  }
  
  func getPageForScrollview(scrollview: UIScrollView) -> Int {
    let height = scrollview.frame.size.height
    return Int((scrollview.contentOffset.y + (0.5 * height)) / height)
  }
  
  func removeTurn() {
    let page = getPageForScrollview(scrollview: turnsScrollView)
    if turns.count > page {
      turns.remove(at: page)
      //Clear the turns from the scrollview:
      _ = turnsScrollView.subviews.map{$0.removeFromSuperview()}
      //Readd and re-frame them:
      for turn in turns {
        turn.frame = CGRect(x: 0, y: 0+CGFloat(turns.index(of: turn)!)*(dimensions.pegSize), width: (self.center.x-insetOfTurnsScrollview)*2, height: dimensions.pegSize)
        turnsScrollView.addSubview(turn)
        turnsScrollView.contentSize = CGSize(width: turn.frame.width, height: CGFloat(turns.count)*(dimensions.pegSize))
      }
    }

  }

  func toPegboardFromProvisionalView() {
    guard game.hasEndSoundBeenPlayed() != true else { return } //Escape if we are in 'limbo' (viewing board after a game)
    var pegsForTurn: [Peg] = Array()
    //Get the page of the scrollview for each position:
    for col in 1...game.getNumInCode() {
      let page = getPageForScrollview(scrollview: memPegStripScrollViews[col-1])
      //Add the Peg visible in the window:
      let array = memoryModel.getColumnOfMemoryPegsNotCrossedInUI(col: col)
      if array.count > page {
        pegsForTurn.append(memoryModel.getColumnOfMemoryPegsNotCrossedInUI(col: col)[page])
      }
    }
    if pegsForTurn.count == game.getNumInCode() {
      let parent = self.parentViewController as! MemoryViewController
      let pegboardViewController = parent.tabBarController?.viewControllers?[0] as! PegboardViewController
      let pegboardView = pegboardViewController.pegBoardView!
      pegboardView.insertTurnReceivedFromPegboard(memoryPegs: pegsForTurn as! [MemoryPeg])
      parent.tabBarController?.selectedIndex = 0
    }else{
      Sound.play(file: "Error.wav")
    }
  }
  
  func toPegboardFromTurnsSelection() {
    guard game.hasEndSoundBeenPlayed() != true else { return } //Escape if we are in 'limbo' (viewing board after a game)
    let page = getPageForScrollview(scrollview: turnsScrollView)
    if turns.count > page {
      let parent = self.parentViewController as! MemoryViewController
      let pegboardViewController = parent.tabBarController?.viewControllers?[0] as! PegboardViewController
      let pegboardView = pegboardViewController.pegBoardView!
      pegboardView.insertTurnReceivedFromPegboard(memoryPegs: turns[page].pegs as! [MemoryPeg])
      parent.tabBarController?.selectedIndex = 0
    }
  }
  
  func undoLastCrossedOffRow() {
    if arrayOfResetStates.count > 0 {
      undoCloseRowButtonTapped(lastResetState: arrayOfResetStates.popLast()!)
    }
  }
  
  func resetAll() {
    //Reset colour count array:
    memoryModel.colourCounts = Array()
    //Reset to init the assumedColours and memPegs
    memoryModel.reinit(gameModel: game)
    resetView()
    memoryModel.ruledOutColours.removeAll()
    _ = turnsScrollView.subviews.map {$0.removeFromSuperview()}
    turns = Array()
    writeAssumedNumber()
    resetUndo()
    showOnlyTicksButton.setShowingOnlyTicks(showingOnly: false)
  }
  
  func resetUndo() {
    arrayOfResetStates.removeAll()
  }
  
  func resetView() {
    memPegStripViews.removeAll()
    memPegStripScrollViews.removeAll()
    self.numRowsVisibleInTopScrollView = self.initialNumRowsVisibleInTopScrollView
    setupUI()
  }
  
  func setupCrossButtons() {
    //Remove all the Close Row Buttons placed in previous calls to this method:
    _ = subviews.filter{$0 is CloseRowButton}.map{$0.removeFromSuperview()}
    if memoryModel.numColoursToShow > 0 {
      for _ in 1...game.getNumInCode() {
        for row in (1...memoryModel.numColoursToShow) {
          setupCrossButton(row: row, col: 0, title: "X", sizeMultiplier: 2/3) //Clicking this also shuts the eye (hides the row’s buttons)
        }
      }
    }
  }
  
  func setupMemoryButton(memPeg: MemoryPeg) {
    let btn = MemoryButton(memPeg: memPeg)
    setButtonTitle(memButton: btn, memPeg: memPeg)
    btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: dimensions.buttonFontSize)
    btn.layer.borderWidth = 1.0
    let (main, text) = self.pegColours[memPeg.row-1]
    btn.backgroundColor = main
    btn.setTitleColor(text, for: UIControlState.normal)
    btn.layer.borderColor = UIColor.white.cgColor
    btn.addTarget(self, action: #selector(incrementSymbol), for: UIControlEvents.touchUpInside)
    self.addSubview(btn)
    btn.isHidden = memPeg.isHidden()
    btn.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(dimensions.pegSize)
      make.height.equalTo(buttonHeight)
      let point: CGPoint = UIHelpers.pointFor(column: memPeg.column, row: memPeg.row, dimensions: dimensions)
      make.centerX.equalTo(point.x)
      make.top.equalTo(pegBoardImageBottom+CGFloat((memPeg.row))*gapHeight+CGFloat(memPeg.row-1)*buttonHeight)
    }
  }

  func setButtonTitle(memButton: MemoryButton, memPeg: MemoryPeg) {
    let symbol: String
    switch memPeg.getState() {
    case DesignatedState.no:
      symbol = cross
    case DesignatedState.yes:
      symbol = tick
    default:
      symbol = "?"
    }
    memButton.setTitle(symbol, for: .normal)
  }
   
  func setupStripOfPegsForColumn(col: Int, scrollToMemoryPeg: MemoryPeg?) {
    //Add the strip of MemoryPegs to the scrollview:
    let colOfPegs = memoryModel.getColumnOfMemoryPegsNotCrossedInUI(col: col)
    let pegStripView: MemPegStripView = MemPegStripView(memPegs: colOfPegs, col: col)
    pegStripView.frame = CGRect(x: 0, y: 0, width: dimensions.pegSize, height: CGFloat(colOfPegs.count)*dimensions.pegSize)
    pegStripView.backgroundColor = UIColor.black
    
    let provisionalScrollview = memPegStripScrollViews[col-1]
    
    //Remove the previously placed MemPegStripView:
    _ = provisionalScrollview.subviews.filter{$0 is MemPegStripView}.map{$0.removeFromSuperview()}
    provisionalScrollview.addSubview(pegStripView)
    provisionalScrollview.contentSize = pegStripView.frame.size
    
    //If the memPegStripViews already contains the a pegStripView with that column, remove it:
    let existingPegStripViewInArray = memPegStripViews.filter{$0.getCol() == col}
    for psv in existingPegStripViewInArray {
      memPegStripViews = memPegStripViews.filter {$0 != psv}
    }
    
    memPegStripViews.append(pegStripView)
    
    var index: Int = 0;
    
    for memoryPeg in colOfPegs {
      let pegStripImageView = addMemoryPeg(memPeg: memoryPeg)
      pegStripView.addSubview(pegStripImageView)
      pegStripImageView.snp.makeConstraints { (make) -> Void in
        make.width.height.equalTo(dimensions.pegSize)
        make.centerX.equalTo(pegStripView.center.x)
        make.top.equalTo(dimensions.pegSize*CGFloat(index))
        index = index + 1
      }
    }
    
    if let scrollToMemoryPeg = scrollToMemoryPeg {
      let countRuledOut = memoryModel.getColumnOfMemoryPegsCrossedInUILessThanRow(col: col, row: scrollToMemoryPeg.row).count
      provisionalScrollview.contentOffset.y = CGFloat(scrollToMemoryPeg.getRow()-1-countRuledOut)*dimensions.pegSize
    }
  }
  
  func addMemoryPeg(memPeg: MemoryPeg) -> MemoryImageView {
    let holeImageView :MemoryImageView = MemoryImageView(memPeg: memPeg);
    holeImageView.image = UIImage(named:memPeg.getPegColour().getPegName())
    holeImageView.tag = memPeg.getPegColour().rawValue
    return holeImageView
  }
  
  func incrementSymbol(sender: MemoryButton!) {
    let memPeg = sender.getMemPeg()
    
    //Increment the MemoryButton's
    let newValue = memPeg.getState().rawValue + 1
    if newValue <= DesignatedState.count {
      let newState = DesignatedState(rawValue: memPeg.getState().rawValue + 1)
      memPeg.setState(state: newState!)
      
      //If DesignatedState == no remove the MemoryImageView from the strip, and of course resize the strip's view.
      if newState == DesignatedState.no {
        removeImageViewFromStripUsingMemoryPeg(memPeg: memPeg)
        memoryModel.ruledOutColours.append(memPeg.getPegColour())
      }else if newState == DesignatedState.yes {
        memoryModel.ruledOutColours.remove(object: memPeg.getPegColour())
        setupStripOfPegsForColumn(col: memPeg.column, scrollToMemoryPeg: memPeg)
      }else if newState == DesignatedState.maybe {
        memoryModel.ruledOutColours.remove(object: memPeg.getPegColour())
        setupStripOfPegsForColumn(col: memPeg.column, scrollToMemoryPeg: nil)
      }
    }else{
      memPeg.setState(state: DesignatedState.maybe)
      memoryModel.ruledOutColours.remove(object: memPeg.getPegColour())
      setupStripOfPegsForColumn(col: memPeg.column, scrollToMemoryPeg: nil)
    }
    //Just update the Memory Button's UI, don't call LayoutSubviews
    setButtonTitle(memButton: sender, memPeg: memPeg)
    writeAssumedNumber()
    updateAccordingToShowOnlyTicks()
  }
  
  func removeImageViewFromStripUsingMemoryPeg(memPeg: MemoryPeg) {
    //Get the correct psv:
    let existingPegStripViewInArray = memPegStripViews.filter{$0.getCol() == memPeg.column}
    for psv in existingPegStripViewInArray {
      for memImageView in psv.subviews {
        let memPegImageView = memImageView as! MemoryImageView
        if memPegImageView.getPeg() == memPeg {
          setupStripOfPegsForColumn(col: memPeg.column, scrollToMemoryPeg: nil)
        }
      }
    }
  }

  func writeAssumedNumber() {
    var columnCounts: [Int] = Array()
    for col in 1...game.getNumInCode() {
      let colOfPegs = memoryModel.getColumnOfMemoryPegsNotCrossedInUI(col: col)
      columnCounts.append(colOfPegs.count)
    }
    if !columnCounts.contains(0) { //Don't want to calculate the number of assumed codes if one slot is empty as this is meaningless...
      let numberAccordingToAssumptions = columnCounts.reduce(1,*)
      memoryModel.setNumStatesBasedOnAssumptions(num: numberAccordingToAssumptions)
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = NumberFormatter.Style.decimal
      let formattedNumber = numberFormatter.string(from: NSNumber(value:memoryModel.getNumStatesBasedOnAssumptions()))
      infoViews[0].text = "Assumed: \(formattedNumber!)"
    }else{
      infoViews[0].text = "Assumed: INVALID"
    }
    
  }
 
}
