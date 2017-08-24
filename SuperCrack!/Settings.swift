//
//  Settings.swift
//  MastermindJune
//
//  Created by Dave Chambers on 24/06/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit

class Settings {
  private var settings: [Setting] = Array()
  
  func getSettings() -> [Setting] {
    return settings
  }
  
  /*
 
   numInCode      = 4  // 4,5 or 6
   numColours     = 6  // 4, 5, 6, 7, 8
   numGuesses     = 10 // 8, 9, 10, 11 or 12. For UI, Guesses MUST be >= numColours
   
   */
  
  init() {
    let defaults = UserDefaults.standard
    
    let persistedNumPegsInCode = defaults.object(forKey: "NumPegsInCode") as? Int ?? 4
    let numPegsInCode = Setting(name: "Number of Positions in the Code", value: persistedNumPegsInCode, minValue: 4, maxValue: 6, position: 1, colour: UIColor.white, textColour: UIColor.black)
    settings.append(numPegsInCode)
    
    let persistedNumColours = defaults.object(forKey: "NumColours") as? Int ?? 6
    let numColours = Setting(name: "Number of Colours", value: persistedNumColours, minValue: 4, maxValue: 8, position: 2, colour: UIColor.white, textColour: UIColor.black)
    settings.append(numColours)
    
    let persistedNumGuesses = defaults.object(forKey: "NumGuesses") as? Int ?? 10
    let numGuesses = Setting(name: "Number of Moves", value: persistedNumGuesses, minValue: 8, maxValue: 12, position: 3, colour: UIColor.white, textColour: UIColor.black)
    settings.append(numGuesses)

  }
  
  func persistData(numPegsInCode: Int, numColours: Int, numGuesses: Int) {
    let defaults = UserDefaults.standard
    defaults.set(numPegsInCode, forKey: "NumPegsInCode")
    defaults.set(numColours, forKey: "NumColours")
    defaults.set(numGuesses, forKey: "NumGuesses")
  }
  
  
  
}
