//
//  MyTabBarController.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 11/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class MyTabBarController: UITabBarController, UITabBarControllerDelegate {
  
  override func viewDidLoad() {
    self.delegate = self
    let pegboard = viewControllers?[0] as! PegboardViewController
    let settingsVC = viewControllers?[2] as! SettingsViewController
    //pass the game to the settings...
    settingsVC.game = pegboard.game
  }
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    
    //Take a screenshot for the Memory View if we left the Pegboard VC:
    
    let pegboard = tabBarController.viewControllers?[selectedIndex] is PegboardViewController
    let memory = tabBarController.viewControllers?[1] is MemoryViewController
    if pegboard && memory {
      let board: PegboardViewController = tabBarController.viewControllers?[selectedIndex] as! PegboardViewController
      let pegboardView = board.pegBoardView!
      let mem: MemoryViewController = tabBarController.viewControllers?[1] as! MemoryViewController
      mem.game = board.game
      mem.memoryModel = MemoryModel(gameModel: mem.game)
      mem.dimensions = board.dimensions
      mem.pegBoard = pegboardView.takeSnapshotForMemoryView()
      mem.memView?.setSnapshot(snap: mem.pegBoard)
      mem.memView?.getPegBoardImageView().image = mem.pegBoard
      board.memoryVC = mem
    }
    
    //If we're leaving the settings page, update them if anything has changed:
    
    if tabBarController.viewControllers?[selectedIndex] is SettingsViewController {
      let settingsVC: SettingsViewController = tabBarController.viewControllers?[selectedIndex] as! SettingsViewController
      var settingsHaveBeenUpdated: Bool = false
      let board: PegboardViewController = tabBarController.viewControllers?[0] as! PegboardViewController
      for setting in board.game.getSettings().getSettings() {
        if setting.getUncommitedValue() != setting.getValue() {
          settingsHaveBeenUpdated = true
        }
      }
      
      if settingsHaveBeenUpdated {
        let settingsAlert = UIAlertController(title: "Save Settings?", message: "Would you like to save the changes made in the settings and restart the game? You will lose your current game data.", preferredStyle: .alert)
        let discardAction = UIAlertAction(title: "Discard", style: .cancel) { action in
          
          //Discard the changes in the Settings:
          _ = board.game.getSettings().getSettings().map{$0.setUncommitedValue(updatedValue: $0.getValue())}
          settingsVC.setView.setNeedsLayout()
        }
        settingsAlert.addAction(discardAction)
        let newGameAction = UIAlertAction(title: "Save", style: .destructive) { action in
          
          //Apply the changes in the Settings:
          let settings = board.game.getSettings().getSettings()
          _ = board.game.getSettings().getSettings().map{$0.setValue(updatedValue: $0.getUncommitedValue())}

          //New Game Logic:
          let pegboardVC: PegboardViewController = tabBarController.viewControllers?[0] as! PegboardViewController
          pegboardVC.restartGame()
          board.game.getSettings().persistData(numPegsInCode: settings[0].getValue(), numColours: settings[1].getValue(), numGuesses: settings[2].getValue())
          let memVC: MemoryViewController = tabBarController.viewControllers?[1] as! MemoryViewController
          memVC.game = board.game
          memVC.memoryModel = MemoryModel(gameModel: memVC.game)
          memVC.dimensions = board.dimensions
          board.memoryVC = memVC
          memVC.setupView()
          tabBarController.selectedIndex = 0 //MUST return to the Pegboard since the UI might have changed and the snapshot in Memory Window looks stupid
        }
        settingsAlert.addAction(newGameAction)
        present(settingsAlert, animated: true, completion: nil)
      }
    }
   

    return true
  }

}
