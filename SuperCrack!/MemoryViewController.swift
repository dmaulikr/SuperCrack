//
//  MemoryViewController.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class MemoryViewController: UIViewController {
    
  //Explicitly unwrapped optionals...
  var game: GameModel!
  var memoryModel: MemoryModel!
  var dimensions: GameDimensions!
  var pegBoard: UIImage!
  
  var memView: MemoryView?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Memory"
    setupView()
  }
  
  func setupView() {
    memView?.removeFromSuperview()
    memView = MemoryView(frame: self.view.frame, game: game, memModel: memoryModel, dimensions: dimensions, pegBoard: pegBoard)
    memView?.backgroundColor = UIColor.black
    self.view.addSubview(memView!)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}
