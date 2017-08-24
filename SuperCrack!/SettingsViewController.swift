//
//  SettingsViewController.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController: UIViewController {
  var game: GameModel!
  var settings: Settings!
  var dimensions: GameDimensions!
  var setView: SettingsView!

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Settings"
    let pegboardVC = tabBarController?.viewControllers?[0] as! PegboardViewController
    setView = SettingsView(frame: self.view.frame, game: game, dimensions: pegboardVC.dimensions)
    self.view.addSubview(setView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }

}
