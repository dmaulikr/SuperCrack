//
//  InstructionsViewController.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 29/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class InstructionsViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Instructions"
    let pegboardVC = tabBarController?.viewControllers?[0] as! PegboardViewController
    let instructionsView = InstructionsView(frame: self.view.frame, dimensions: pegboardVC.dimensions)
    self.view.addSubview(instructionsView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}
