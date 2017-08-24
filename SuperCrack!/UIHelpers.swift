//
//  UIHelpers.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class UIHelpers{
  
  /**
   Takes a column and row and returns a point
   */
  static func pointFor(column: Int, row: Int, dimensions: GameDimensions) -> CGPoint {
    return CGPoint(
      x: CGFloat(CGFloat(column) * dimensions.horzInc) + CGFloat(dimensions.horzInc/2),
      y: CGFloat(dimensions.usableHeight - CGFloat(row) * dimensions.vertInc) + CGFloat(dimensions.vertInc/2))
  }
  
  /**
   Takes a point and returns a column and row - the inverse of the above
   */
  static func convertPoint(point: CGPoint, dimensions: GameDimensions) -> (inMainBoard: Bool, column: Int, row: Int) {
    let column = (point.x - CGFloat(dimensions.horzInc/2)) / dimensions.horzInc
    let row = (point.y - CGFloat(dimensions.vertInc/2) - dimensions.usableHeight ) / -dimensions.vertInc
    if dimensions.mainAreaFrame.contains(point){
      return (true, Int(round(column)), Int(round(row)))
    } else {
      return (false, Int(round(column)), Int(round(row)))
    }
  }

}
