//
//  UICommon.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


struct GameDimensions {
  
  let tabBarHeight: CGFloat
  let usableHeight: CGFloat
  let usableWidth: CGFloat
  
  let numHorzUnits: Int
  let numVertUnits: Int
  let horzInc: CGFloat
  let vertInc: CGFloat
  let tileSize: CGFloat
  
  let pegSize: CGFloat
  let pegPadding: CGFloat
  let buttonFontSize: CGFloat
  let settingsButtonFontSize: CGFloat
  
  let sectionWidth: CGFloat
  let numPegsAcross: Int
  let boardCount: Int
  
  let mainAreaWidth: CGFloat
  let mainAreaFrame: CGRect
  
  let backgroundGrey: UIColor
  
  init (game: GameModel, tabBarHeight:CGFloat, vcHeight: CGFloat) {
    self.tabBarHeight = tabBarHeight
    self.usableHeight = CGFloat(vcHeight - self.tabBarHeight)
    self.usableWidth  = UIScreen.main.bounds.width
    
    self.numHorzUnits = game.getNumInCode()+2
    self.numVertUnits = game.getNumGuesses()+1
    
    self.horzInc = usableWidth/CGFloat(numHorzUnits)
    self.vertInc = usableHeight/CGFloat(numVertUnits)
    
    /*
     
     Since we want the game to look good on iPhone and iPad, we need the correct tileSize...
     
     components needed in the x direction = num in code + 2 (side sections for left palette and right feedback view/ turn buttons)
     
     components needed in the y direction = num turns + 1 (for the hidden code)
     
     Calculate, which is bigger:
     
     UIScreen.main.bounds.width/(CGFloat(GameSettings.numInCode)+2) or UIScreen.main.bounds.height/(CGFloat(GameSettings.numGuesses)+1)
     
     Then, since we want the tiles to be square and fit on the screen, choose a tile size that is the width and height of the smaller of the above....
     
     */
    
    self.tileSize = usableWidth/CGFloat(numHorzUnits) > usableHeight/CGFloat(numVertUnits) ? usableHeight/CGFloat(numVertUnits) : usableWidth/CGFloat(numHorzUnits)
    
    //Dependent on tileSize:
    self.pegPadding               = tileSize*0.0732
    self.pegSize                  = tileSize-pegPadding
    self.buttonFontSize           = tileSize/2
    self.settingsButtonFontSize   = tileSize/4
    
    self.sectionWidth   = usableWidth/CGFloat(game.getNumInCode()+2) //width / numInCode +2 since we have left palette and right turn/feedback view
    self.numPegsAcross  = game.getNumInCode()+1
    self.boardCount     = numPegsAcross * game.getNumRowsToUse()
    
    self.mainAreaWidth  = self.sectionWidth*CGFloat(game.getNumInCode())
    self.mainAreaFrame  = CGRect(x: (usableWidth/2)-0.5*mainAreaWidth, y:CGFloat(0), width: mainAreaWidth, height: usableHeight)
    
    self.backgroundGrey = UIColor(red: 0.81, green: 0.81, blue: 0.81, alpha: 1.00)
  }
  
}
