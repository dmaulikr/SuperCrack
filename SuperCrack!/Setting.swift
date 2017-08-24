//
//  Setting.swift
//  MastermindJune
//
//  Created by Dave Chambers on 25/06/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit

class Setting: CustomStringConvertible {
  private var name:               String
  private var value:              Int
  private var uncommitedValue:    Int
  private var minValue:           Int
  private var maxValue:           Int
  private var position:           Int
  private var colour:             UIColor
  private var textColour:         UIColor
  
  init(name: String, value: Int, minValue: Int, maxValue: Int, position: Int, colour: UIColor, textColour: UIColor) {
    self.name = name
    self.value = value
    self.uncommitedValue = value
    self.minValue = minValue
    self.maxValue = maxValue
    self.position = position
    self.colour = colour
    self.textColour = textColour
  }
  
  var description: String {
    return "Name:\(name) \tValue:\(value)\n"
  }
  
  func getName() -> String {
    return self.name
  }
  
  func getValue() -> Int {
    return self.value
  }
  
  func setValue(updatedValue: Int) {
    self.value = updatedValue
  }
  
  
  func getUncommitedValue() -> Int {
    return self.uncommitedValue
  }
  
  func setUncommitedValue(updatedValue: Int) {
    self.uncommitedValue = updatedValue
  }
  
  func getMin() -> Int {
    return self.minValue
  }
  
  func getMax() -> Int {
    return self.maxValue
  }
  
  func getPosition() -> Int {
    return self.position
  }
  
  func getColour() -> UIColor {
    return self.colour
  }
  
  func getTextColour() -> UIColor {
    return self.textColour
  }
  
}
