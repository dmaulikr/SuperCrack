//
//  InstructionsView.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 31/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit

class InstructionsView: UIView {
  
  private let dimensions: GameDimensions
  private let scrollview = UIScrollView()
  
  init(frame: CGRect, dimensions: GameDimensions){
    self.dimensions = dimensions
    super.init(frame: frame)
    
    self.addSubview(scrollview)
    scrollview.backgroundColor = dimensions.backgroundGrey
    scrollview.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(0)
      make.height.equalTo(self.frame.height - dimensions.tabBarHeight)
      make.width.equalTo(self.frame.width)
    }
    
    let offset2 = makeParagraph(yOffset: 10.0, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "The aim of the game with SuperCrack! is to crack the hidden code. It's a challenging and fun game of deduction.")
    let offset3 = makeParagraph(yOffset: offset2, fontSize: dimensions.settingsButtonFontSize, fontIsBold: true, text: "Colour Board:")
    let offset4 = makeParagraph(yOffset: offset3, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "The Colour Board tab features a palette of colours on the left which the player can drag into the central area to form a move.")
    let offset5 = makeImage(yOffset: offset4, imageNumber: "1", sizeMultiplier: 1.0)
    let offset6 = makeParagraph(yOffset: offset5, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "A move consists of a full row of colours. The moves are numbered on the right side of the screen, beginning with 1. The code is hidden behind the question marks at the top of the screen. A move is made by pressing the numbered button for that row. Feedback will be given in that same area for each move made. The feedback consists of two numbers, the top number indicates how many in the move are correct colours but in an incorrect position and the bottom number shows how many in the move are both the correct colour and in the correct position. The feedback below therefore means that in that move, 3 colours are correct but in an incorrect position and there is 1 colour that is both the correct colour and in the correct position.")
    let offset7 = makeImage(yOffset: offset6, imageNumber: "2", sizeMultiplier: 2.0)
    let offset8 = makeImage(yOffset: offset7-10, imageNumber: "3", sizeMultiplier: 1.0) //-10 looks better with two images in a row
    let offset9 = makeParagraph(yOffset: offset8, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "The game is over when the moves run out or the code is cracked!")
    let offset10 = makeParagraph(yOffset: offset9, fontSize: dimensions.settingsButtonFontSize, fontIsBold: true, text: "Memory View:")
    let offset11 = makeParagraph(yOffset: offset10, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "The Memory View tab is in no way necessary for the game. The player can ignore it but it's been designed to help assist the player and reduce the cognitive load on their memory, allowing them to enjoy cracking the code. Indeed, one of the aims of SuperCrack! was to take away the need for pen and paper when tackling the game.")
    let offset12 = makeImage(yOffset: offset11, imageNumber: "4", sizeMultiplier: 1.0)
    let offset13 = makeParagraph(yOffset: offset12, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "The top panel contains a window to the Colour Board which can be scrolled. This window expands as the player eliminates impossible colours, reducing the rows. A row is removed via the 'X' button on the left and has a handy button on the right to allow the player to mark how many of that colour they think the code contains. The 'UNDO' button allows the player to add back the last eliminated colour. In the current game, we already know there are 2 reds, 1 green and 1 purple:")
    let offset14 = makeImage(yOffset: offset13, imageNumber: "5", sizeMultiplier: 1.0)
    let offset15 = makeParagraph(yOffset: offset14, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "Between the 'X' buttons on the left and the numbers on the right are a set of buttons that rotate between a '?' (the default), meaning the player doesn't know if that position contains that colour, a '\(cross)', indicating the player thinks that colour is not present in the code at that position, and a '\(tick)' to mean the player thinks that the colour exists in that position. The box at the bottom centre shows how many codes are possible (this never changes during the game) and how many are assumed, based on what is either marked as a '?' or a '\(tick)' in that column. If the player has reduced the problem to one possible code then the 'Assumed' box will show the number 1.")
    let offset16 = makeImage(yOffset: offset15, imageNumber: "6", sizeMultiplier: 1.0)
    let offset17 = makeParagraph(yOffset: offset16, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "To the left and right of this area are two buttons that operate only on columns with a '\(tick)' in them. The right side features a '? -> \(cross)' button which, for each column with a '\(tick)', makes the '?' buttons '\(cross)' buttons. This is useful when the player is sure a colour exists in that position as it saves them manually crossing off the '?'s in that column. The left side features a '\(tick)' button which will, on a column by column basis, hide the '?' and '\(cross)' buttons, useful for showing where the '\(tick)'s are as shown below.")
    let offset18 = makeImage(yOffset: offset17, imageNumber: "7", sizeMultiplier: 1.0)
    let offset19 = makeParagraph(yOffset: offset18, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "The circles below the grid of rectangular buttons reflect what is in each column, either ticked or marked with a question mark and these areas can be scrolled if there is more than one option for that position. Once the player has a row of circles that they think might be the code, they may send that row directly to the Colour Board using the button on the left or send it down to another scrollable area below (which can contain many moves) using the button on the right. To remove a move from the lower area, press the '-' button to it's right. Note that the scrollable area at the bottom can also send a move directly to the Colour Board. Finally, the entire Memory View can be reset using the lower right reset button, clearing any assumptions the player has made about the game.")
    let offset20 = makeParagraph(yOffset: offset19, fontSize: dimensions.settingsButtonFontSize, fontIsBold: true, text: "Settings View:")
    let offset21 = makeImage(yOffset: offset20, imageNumber: "8", sizeMultiplier: 1.0)
    let offset22 = makeParagraph(yOffset: offset21, fontSize: dimensions.settingsButtonFontSize, fontIsBold: false, text: "The Settings tab features three sliders to control the game parameters. The 'Number of Positions in the Code' controls how many positions are in the code, note that colours may be repeated. The 'Number of Colours' controls how many colours are used. These two parameters control how many possible codes there are, ranging from 256 possible codes with 4 positions and 4 colours to 262,144 possible codes with 6 positions and 8 colours. The third setting, 'Number of Moves' controls how many moves the player gets to discover the code. Good luck!")
    
    scrollview.contentSize = CGSize(width: self.frame.width, height: 10.0 + offset22)
    
  }
  
  func makeImage(yOffset: CGFloat, imageNumber: String, sizeMultiplier: CGFloat) -> CGFloat {
    let image = UIImage(named:"Instructions" + imageNumber)
    let instrctions = UIImageView()
    instrctions.image = image
    scrollview.addSubview(instrctions)
    let imageHeight = makeRatioForImage(image: image!)*(image?.size.width)!
    instrctions.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(yOffset+10)
      make.height.equalTo(imageHeight*sizeMultiplier)
      make.width.equalTo((image?.size.width)!*sizeMultiplier)
      make.centerX.equalTo(self.center.x)
    }
    return yOffset + 20 + imageHeight*sizeMultiplier
  }
  
  func makeRatioForImage(image: UIImage) -> CGFloat {
    let width = image.size.width
    let height = image.size.height
    return height/width
  }
  
  func makeParagraph(yOffset: CGFloat, fontSize: CGFloat, fontIsBold: Bool, text: String) -> CGFloat {
    let textView = UITextView(frame: CGRect(x: 10.0, y: yOffset, width: self.frame.width-20, height: 100.0))
    textView.textAlignment = NSTextAlignment.justified
    if fontIsBold {
      textView.font = UIFont.boldSystemFont(ofSize: fontSize*2)
    }else{
      textView.font = UIFont.systemFont(ofSize: fontSize)
    }
    textView.isUserInteractionEnabled = false
    textView.text = text
    scrollview.addSubview(textView)
    
    let fixedWidth = textView.frame.size.width
    textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    var newFrame = textView.frame
    newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    textView.frame = newFrame;
    
    return newSize.height+yOffset
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  
}

