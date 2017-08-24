//
//  PegboardView.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import SnapKit
import SwiftySound
import UIKit


class PegBoardView: UIView {
  
  private let dimensions: GameDimensions
  private let game:       GameModel
  private var snapPointImageViews: [UIImageView]
  private let leftPaletteArea       = UIView()
  private let mainPlayArea          = UIView()
  private let turnAndFeedbackArea   = UIView()
  private var draggedPegImageView: UIImageView?
  private var closestPegImageView: UIImageView = UIImageView()
  private var turnButtons: [UIButton] = Array()
  
  init(frame: CGRect, dimensions: GameDimensions, game:GameModel){
    self.dimensions = dimensions
    self.game = game
    self.snapPointImageViews = [UIImageView] (repeating: UIImageView(), count: dimensions.boardCount) //Snap Points array will hold the UIImageViews, most of which will be snap points
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.orange
    
    //Left Palette Area:
    
    leftPaletteArea.backgroundColor = UIColor.black
    self.addSubview(leftPaletteArea)
    leftPaletteArea.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(self.dimensions.sectionWidth)
      make.height.equalTo(self.dimensions.usableHeight)
      make.left.equalTo(0)
      make.top.equalTo(0)
    }

    //Main Play Area:
    
    mainPlayArea.backgroundColor = dimensions.backgroundGrey
    self.addSubview(mainPlayArea)
    mainPlayArea.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(self.dimensions.sectionWidth*CGFloat(game.getNumInCode()))
      make.height.equalTo(self.dimensions.usableHeight)
      make.centerX.equalTo(self.center)
      make.top.equalTo(0)
    }

    //Turn and Feedback Area:
    
    turnAndFeedbackArea.backgroundColor = UIColor.black
    self.addSubview(turnAndFeedbackArea)
    turnAndFeedbackArea.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(self.dimensions.sectionWidth)
      make.height.equalTo(self.dimensions.usableHeight)
      make.left.equalTo(self.frame.width-self.dimensions.sectionWidth)
      make.top.equalTo(0)
    }
    
    addShowCodeButton()
    //Turn buttons that will become Feedback area after being pushed:
    addTurnButtons()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  func addShowCodeButton() {
    let button = UIButton()
    self.addSubview(button)
    button.snp.makeConstraints { (make) -> Void in
      make.width.height.equalTo(self.dimensions.pegSize)
      make.center.equalTo(UIHelpers.pointFor(column: game.getNumInCode()+1, row: game.getNumRowsToUse(), dimensions: self.dimensions))
    }
    button.backgroundColor = UIColor.black
    button.setTitle("Quit", for: .normal)
    button.addTarget(self, action: #selector(showCodeButtonAction), for: .touchUpInside)
    button.isEnabled = true
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.dimensions.buttonFontSize*2/3)
    button.setTitleColor(UIColor.white, for: .normal)
  }
  
  func showCodeButtonAction(sender: UIButton!) {
    Sound.play(file: "Turn.wav")
    if game.hasEndSoundBeenPlayed() == true {
      self.endGame(won: self.game.isGameWon() ? true : false)
    }else{
      let parent = self.parentViewController as! PegboardViewController
      parent.reallyQuit{success in
        if success == true {
          self.endGame(won: self.game.isGameWon() ? true : false)
        }
      }
    }
    
  }
  
  func addTurnButtons() {
    for button in turnButtons {
      button.removeFromSuperview()
    }
    turnButtons.removeAll()
    for i in 1...game.getNumGuesses() {
      let image = UIImage(named: String(describing: i)) as UIImage?
      let turnButton = UIButton(type: UIButtonType.custom) as UIButton
      turnButton.setImage(image, for: UIControlState.normal)
      turnButton.addTarget(self, action: #selector(turnButtonAction), for: .touchUpInside)
      turnButton.isEnabled = i == game.getTurnNumber() ? true : false //Only row 1 button is enabled at first
      self.addSubview(turnButton)
      turnButton.snp.makeConstraints { (make) -> Void in
        make.width.height.equalTo(self.dimensions.pegSize)
        make.center.equalTo(UIHelpers.pointFor(column: game.getNumInCode()+1, row: i, dimensions: self.dimensions))
      }
      turnButtons.append(turnButton)
    }
  }
  
  func turnButtonAction(sender: UIButton!) {
    if game.getTurnNumber() == game.getNumGuesses() {
      //If the Turn has a colour in each hole then make the button enabled ....
      if game.assessIfTurnCanBeTakenForRow() {
        displayFeedback(button: sender)
        let (_, _) = game.calculateFeedback() //Necessary to see if the game is won or not
        endGame(won: game.isGameWon() ? true : false)
      }else{
        Sound.play(file: "Error.wav")
      }
    }else{
      //If the Turn has a colour in each hole then make the button enabled ....
      if game.assessIfTurnCanBeTakenForRow() {
        displayFeedback(button: sender)
        game.incrementTurn()
        if game.isGameWon() {
          endGame(won: true)
        }else{
          Sound.play(file: "Turn.wav")
        }
        turnButtons[game.getTurnNumber()-1].isEnabled = game.isGameBeingPlayed() //If the game is still in play, enable the next turn button
      }else{
        Sound.play(file: "Error.wav")
      }
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    //Remove all the views placed in previous calls to this method:
    _ = subviews.filter{$0.tag != 0}.map{$0.removeFromSuperview()}
    //Place the Pegs.....
    for hole in game.getBoardHoles() {
      if let staticPeg = hole.getStaticPeg() {
        let sPeg = addPeg(peg: staticPeg, hole: hole)
        //Don't want the dragged Pegs to snap to the void (invisible) top left positions or the code holes (which will later be covered) but want to snap to all other points...
        if !sPeg.isHidden && hole.getHoleType() != HoleType.codeHole {
          snapPointImageViews[game.getSnapPointArrayIndexGivenColumnAndRow(col: staticPeg.getColumn(), row: staticPeg.getRow())] = sPeg
        }
      }
      if let dynamicPeg = hole.getDynamicPeg() {
        let dPeg = addPeg(peg: dynamicPeg, hole: hole)
        dPeg.isUserInteractionEnabled = dynamicPeg.isDraggable()
      }
    }
    //Cover the code Pegs:
    if game.isGameBeingPlayed() {
      addCodeCovers()
    }
    //printPegBoard()
    //assertGameState()
  }
  
  func addPeg(peg: Peg, hole: Hole) -> UIImageView {
    let holeImageView :UIImageView = UIImageView();
    holeImageView.frame.size = CGSize(width: dimensions.pegSize, height: dimensions.pegSize)
    holeImageView.center = UIHelpers.pointFor(column: peg.getColumn(), row: peg.getRow(), dimensions: dimensions)
    holeImageView.image = UIImage(named:peg.getPegColour().getPegName())
    holeImageView.isHidden = hole.isHidden()
    holeImageView.tag = peg.getPegColour().rawValue
    self.addSubview(holeImageView)
    return holeImageView
  }
  
  func addCodeCovers() {
    for i in 1...game.getNumInCode() {
      let coverLabel :UILabel = UILabel();
      coverLabel.frame.size = CGSize(width: dimensions.pegSize, height: dimensions.pegSize)
      coverLabel.center = UIHelpers.pointFor(column: i, row: game.getNumGuesses()+1, dimensions: dimensions)
      coverLabel.tag = -1
      coverLabel.text = "?"
      coverLabel.textAlignment = .center
      coverLabel.font = UIFont.boldSystemFont(ofSize: self.dimensions.buttonFontSize)
      coverLabel.textColor = UIColor.white
      coverLabel.backgroundColor = UIColor.black
      self.addSubview(coverLabel)
    }
  }
  
  func assertGameState() {
    //There should be 2 UIImageViews on each spot, except the code Pegs which feature 1 UIImageView.  And more...
    assertPegProperties()
  }
  
  func assertPegProperties() {
    var codePegCentres: [CGPoint] = Array()
    var otherCentres: [CGPoint] = Array()
    let pegImageViews = self.subviews.filter{$0 is UIImageView && $0.tag != 0}
    for imgView in pegImageViews {
      let (_, col, row) = UIHelpers.convertPoint(point: imgView.center, dimensions: dimensions)
      if row == game.getNumRowsToUse() {
        codePegCentres.append(imgView.center)
      }else{
        otherCentres.append(imgView.center)
      }
      let hole = game.getHoleForPosition(column: col, row: row)
      let (staticPeg, dynamicPeg) = hole.getPegPair()
      if let staticPeg = staticPeg, let dynamicPeg = dynamicPeg   {
        if row != game.getTurnNumber() && row <= game.getNumGuesses() {
          assert(staticPeg.getPegColour() == dynamicPeg.getPegColour())                       //Assert Static and Dynamic Pegs are the same colour....
          assert(staticPeg.isDraggable() == false)                                            //Assert Static Peg's Interaction is disabled....
          assert(dynamicPeg.isDraggable() == (dynamicPeg.getPegColour() != PegColour.noPeg))  //The Dynamic Pegs UI is enabled only if the Peg has a colour
        }else if row == game.getNumRowsToUse(){
          assert(staticPeg.getPegColour() != PegColour.noPeg)                                 //Each Peg in the Code row has a colour
        }
      }
    }
    //Partition the CGPoints into groups:
    let otherCentreGroups = Set<CGPoint>(otherCentres).map{ value in return otherCentres.filter{$0==value} }
    for centrePair in otherCentreGroups {
      assert(centrePair.count == 2)
    }
    let codePegCentreGroups = Set<CGPoint>(codePegCentres).map{ value in return codePegCentres.filter{$0==value} }
    for shouldBeSingle in codePegCentreGroups {
      assert(shouldBeSingle.count == 1)
    }
  }

  func printPegBoard() {
    for row in (1...game.getNumRowsToUse()).reversed() { //Reversed is used since we want to display the top left data first and work our way to bottom right
      var desc: String = String()
      for column in 0..<dimensions.numPegsAcross {
        let hole  = game.getHoleForPosition(column: column, row: row)
        
        var leftStaticPart: String
        var rightDynamicPart: String
        
        if let staticPeg = hole.getStaticPeg() {
          leftStaticPart = staticPeg.getPegColour().getPegLetter()
        }else{
          leftStaticPart = "-"
        }
        
        if let dynamicPeg = hole.getDynamicPeg() {
          rightDynamicPart = dynamicPeg.getPegColour().getPegLetter()
        }else{
          rightDynamicPart = "-"
        }
        
        let imageViewsAtPoint: [UIImageView] = getUIPegsOnPoint(point: UIHelpers.pointFor(column: column, row: row, dimensions: dimensions))
        assert(imageViewsAtPoint.count <= 2) // Should never be more that 2 Pegs in a Hole (Static + Dynamic)
        
        var uiAndModelMatchForStatic: String?
        var uiAndModelMatchForDynamic: String?
        
        for imageView in imageViewsAtPoint {
          if PegColour.getColourLetter(index: imageView.tag) == leftStaticPart {
            uiAndModelMatchForStatic = leftStaticPart
          }
          if PegColour.getColourLetter(index: imageView.tag) == rightDynamicPart {
            uiAndModelMatchForDynamic = rightDynamicPart
          }
        }
        
        var staticCode: String
        if hole.getHoleType() == HoleType.voidHole {
          staticCode = " "
        }else if let match = uiAndModelMatchForStatic {
          staticCode = match
        }else{
          staticCode = "*" //Make an error sound
        }
        
        var dynamicCode: String
        if hole.getHoleType() == HoleType.voidHole {
          dynamicCode = " "
        }else if hole.getHoleType() == HoleType.codeHole {
          dynamicCode = "^"
        }else if let match = uiAndModelMatchForDynamic {
          dynamicCode = match
        }else{
          dynamicCode = "*" //Make an error sound
          Sound.play(file: "Error.wav")
        }
        desc = desc + "\t\((column, row)) = \((staticCode, dynamicCode)) \t|"
      }
      print("\n \(desc)")
    }
    print("\n\n")
  }
  
  func displayFeedback(button: UIButton) {
    button.isHidden = true
    let feedbackView: FeedbackView = FeedbackView(frame: self.frame, dimensions: dimensions, game: game)
    feedbackView.backgroundColor = UIColor.white
    feedbackView.layer.cornerRadius = 10
    self.addSubview(feedbackView)
    feedbackView.snp.makeConstraints { (make) -> Void in
      make.width.height.equalTo(dimensions.pegSize)
      make.center.equalTo(UIHelpers.pointFor(column: game.getNumInCode()+1, row: game.getTurnNumber(), dimensions: dimensions))
    }
  }
  
  func endGame(won: Bool) {
    _ = self.subviews.filter{$0.tag == -1}.map{$0.removeFromSuperview()}
    game.showCodeHoles()
    for turnButton in turnButtons {
      turnButton.isEnabled = false
    }
    setNeedsLayout()
    let parent = self.parentViewController as! PegboardViewController
    if won && game.isGameBeingPlayed() {
      Sound.play(file: "Win.wav")
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { //Allow the Win sound time to play
        parent.finaliseGame(won: won, pegBoardView: self)
        self.game.setEndSoundBeenPlayed(played: true)
      })
    }else{
      if game.hasEndSoundBeenPlayed() {
        parent.finaliseGame(won: won, pegBoardView: self)
      }else{
        Sound.play(file: "Lose.wav")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { //Allow the Lose sound time to play
          parent.finaliseGame(won: won, pegBoardView: self)
          self.game.setEndSoundBeenPlayed(played: true)
        })
      }
    }
    game.setGameBeingPlayed(played: false)
  }
  
  func reactivateTurnOne() {
    turnButtons[0].isEnabled = true
  }
  
  func takeSnapshotForMemoryView() -> UIImage {
    let rect = CGRect(
      origin: CGPoint(x: 0, y: dimensions.vertInc),
      size: CGSize(width: dimensions.usableWidth, height: dimensions.usableHeight - dimensions.vertInc)
    )
    return imageSnapshotCroppedToFrame(frame: rect)
  }
  
  //MARK: Dragging related Functions:
  
  func safelyFindClosestPeg(index: Int) -> Int {
    let ret: Int = 0
    if index < snapPointImageViews.count && index >= 0 {
      return index
    }
    return ret
  }
  
  func getUIPegsOnPoint(point: CGPoint) -> [UIImageView] {
    var ret = [UIImageView]()
    let myImageViews = self.subviews.filter{$0 is UIImageView}
    for imgView in myImageViews {
      if imgView.center == point {
        ret.append(imgView as! UIImageView)
      }
    }
    return ret
  }
  
  func resetDrag() {
    draggedPegImageView = nil
  }
  
  func highlightHole() {
    if closestPegImageView != draggedPegImageView && mainPlayArea.frame.contains(closestPegImageView.frame) {
      let (_, _, row) = UIHelpers.convertPoint(point: closestPegImageView.center, dimensions: dimensions)
      let imageViewsAtPoint: [UIImageView] = getUIPegsOnPoint(point: closestPegImageView.center)
      for view in imageViewsAtPoint {
        view.layer.borderWidth = 4
        view.layer.borderColor = row == game.getTurnNumber() ? UIColor.black.cgColor : UIColor.clear.cgColor
      }
    }
  }
  
  func resetBordersOnPegs() {
    let myImageViews = self.subviews.filter{$0 is UIImageView}
    for imgView in myImageViews {
      imgView.layer.borderWidth = 0
      imgView.layer.borderColor = UIColor.clear.cgColor
    }
  }
  
  /**
   Ensure the touch is inside the circular peg
   */
  func touchIsInsidePeg(centreOfImageView: CGPoint, locationInImgView: CGPoint) -> Bool {
    let xDist = centreOfImageView.x - locationInImgView.x
    let yDist = centreOfImageView.y - locationInImgView.y
    let dist = sqrt((xDist * xDist) + (yDist * yDist))
    var isInside: Bool = false
    if dist < dimensions.pegSize/CGFloat(2){
      isInside = true
    }
    return isInside
  }
  
  /**
   If the Dragged Peg is within a certain distance of the closest peg, snap it to that peg
   */
  func draggedPegShouldSnapToNearest(draggedCentre: CGPoint, closestCentre: CGPoint) -> Bool {
    let holeOfPegOrigin: Hole = game.getHoleForPeg(peg: game.getDraggedPeg())
    if holeOfPegOrigin.getHoleType() == HoleType.paletteHole && draggedPegImageView == closestPegImageView { //Should only return false if we are dealing with a Palette Peg since they shouldn't snap
      return false
    }
    let xDist = draggedCentre.x - closestCentre.x
    let yDist = draggedCentre.y - closestCentre.y
    let dist = sqrt((xDist * xDist) + (yDist * yDist))
    var shouldSnap: Bool = false
    if dist < dimensions.pegSize/CGFloat(6){
      shouldSnap = true
    }
    return shouldSnap
  }
  
  func reportMove(move: Move) {
    //print("Move reported: \(move)")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard game.isGameBeingPlayed() else { return } //Prevent any dragging of pegs if the game is over
    guard let touch = touches.first else { return }
    if touch.view is UIImageView{
      let imgView = touch.view as! UIImageView
      let location = touch.location(in: self)
      if touchIsInsidePeg(centreOfImageView: imgView.center, locationInImgView: location){ //Ensure the touch is inside the circular peg
        let (_, column, row) = UIHelpers.convertPoint(point: location, dimensions: dimensions)
        if let peg = game.getDynamicPegForPoint(column: column, row: row) {
          peg.setIsBeingDragged(isBeingDragged: true) //Set the Peg as beingDragged
          closestPegImageView = snapPointImageViews[safelyFindClosestPeg(index: game.getSnapPointArrayIndexGivenColumnAndRow(col: column, row: row))]
          draggedPegImageView = imgView
          draggedPegImageView?.center = location
        }
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first, let dragged = draggedPegImageView {
      let location = touch.location(in: self)
      let (_, column, row) = UIHelpers.convertPoint(point: location, dimensions: dimensions)
      closestPegImageView = snapPointImageViews[safelyFindClosestPeg(index: game.getSnapPointArrayIndexGivenColumnAndRow(col: column, row: row))]
      resetBordersOnPegs()
      highlightHole()
      if draggedPegShouldSnapToNearest(draggedCentre: dragged.center, closestCentre: closestPegImageView.center) {
        dragged.center = closestPegImageView.center
      }else{
        dragged.center = touch.location(in: self)
      }
      dragged.layer.zPosition = closestPegImageView.layer.zPosition+1 //Keeps the dragged Peg above the Pegs we drag over
    }
    //If a peg goes into the Left Palette or the Turn/ Feedback View, make it snap to the peg with that same colour....
    if let dragged = draggedPegImageView {
      if !mainPlayArea.frame.intersects(dragged.frame) {
        let draggedPegImageViewFromModel = game.getDraggedPeg()
        let colourPaletteIndex = game.getNumColours()-draggedPegImageViewFromModel.getPegColour().rawValue+1
        dragged.center = snapPointImageViews[safelyFindClosestPeg(index: game.getSnapPointArrayIndexGivenColumnAndRow(col: 0, row: colourPaletteIndex))].center
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first, let dragged = draggedPegImageView {
      let location = touch.location(in: self)
      let (inMainBoard, column, row) = UIHelpers.convertPoint(point: location, dimensions: dimensions)
      let pegWeDragged = game.getDraggedPeg()
      pegWeDragged.setIsBeingDragged(isBeingDragged: false)
      resetDrag()
      resetBordersOnPegs()
      dragged.center = UIHelpers.pointFor(column: pegWeDragged.getColumn(), row: pegWeDragged.getRow(), dimensions: dimensions) //Return the dynamic peg we dragged back to it's spot
      if inMainBoard, row == game.getTurnNumber() {
          if let endPeg = game.getDynamicPegForPoint(column: column, row: row) {
            let endHole: Hole = game.getHoleForPeg(peg: endPeg)
            if let dynamicPeg = endHole.getDynamicPeg() {
              dynamicPeg.setPegColour(newPegColour: pegWeDragged.getPegColour())                                  //Set the colour of the dynamic destination peg.  Static colour will only be set at the end of the Turn.
              dynamicPeg.setDraggable(isDraggable: true)                                                          //Make the Dynamic Peg in the Destination Draggable
              let startHole: Hole = game.getHoleForPeg(peg: pegWeDragged)
              if startHole.getHoleType() == HoleType.playableHole && startHole.getRow() == endHole.getRow() {
                //Set the colour to no colour to give the impression we are dragging the Peg to another Hole in the Turn BUT ONLY if the start and end are in the same turn
                if let startHoleDynamicPeg = startHole.getDynamicPeg() {
                  startHoleDynamicPeg.setPegColour(newPegColour: PegColour.noPeg)
                }
              }
              reportMove(move: Move(pegA: pegWeDragged, pegB: dynamicPeg))
              Sound.play(file: "Snap.wav")
            }
        }else{
          //Dragged a Peg onto a spot NOT in the current Turn
          Sound.play(file: "ReverseSnap.wav")
        }
      }else{
        let startHole: Hole = game.getHoleForPeg(peg: pegWeDragged)
        if pegWeDragged.getRow() == game.getTurnNumber() && startHole.getHoleType() == HoleType.playableHole { //Here, since we are moving from the current Turn, we want a drag offscreen to move the peg from that hole, just like it would in real life.  But it must be a playable hole we are dragging otherwise a dragged palette hole will have it's dynamic peg set to 'noPeg'
          if let startHoleDynamicPeg = startHole.getDynamicPeg() {
            startHoleDynamicPeg.setPegColour(newPegColour: PegColour.noPeg) //Set the colour to no colour to give the impression we are dragging the Peg to another Hole in the Turn BUT ONLY if the start and end are in the same turn
          }
        }
        Sound.play(file: "ReverseSnap.wav")
      }
      setNeedsLayout()
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    resetDrag()
    touchesEnded(touches, with: event)
  }
  
  func insertTurnReceivedFromPegboard(memoryPegs: [MemoryPeg]) {
    //print("Received from Memory View the data: \(memoryPegs)")
    for peg in memoryPegs {
      let endPeg = game.getDynamicPegForPoint(column: peg.column, row: game.getTurnNumber())
      let endHole: Hole = game.getHoleForPeg(peg: endPeg!)
      let dynamicPeg = endHole.getDynamicPeg()
      dynamicPeg!.setPegColour(newPegColour: peg.getPegColour())
      dynamicPeg!.setDraggable(isDraggable: true)
    }
    setNeedsLayout()
    Sound.play(file: "Snap.wav")
  }

  
}
