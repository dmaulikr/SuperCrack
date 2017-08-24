//
//  PegboardViewController.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class PegboardViewController: UIViewController {
   
  var memoryVC: MemoryViewController?
  let game = GameModel()
  var pegBoardView: PegBoardView!
  var dimensions: GameDimensions!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Colour Board"
    setupDimensionsAndGame()
  }
  
  func updateGeometry() {
    pegBoardView.removeFromSuperview()
    setupDimensionsAndGame()
  }
  
  func setupDimensionsAndGame() {
    //Set the Game Dimensions Global Struct....
    dimensions = GameDimensions(game: game, tabBarHeight:(self.tabBarController?.tabBar.frame.size.height)!, vcHeight: self.view.frame.height)
    game.setupGameModel(dimensions: dimensions)
    pegBoardView = PegBoardView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: dimensions.usableHeight), dimensions: dimensions, game: game)
    self.view.addSubview(pegBoardView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }

  func reallyQuit(completionHandler:@escaping (Bool) -> ()) {
    let reallyQuitAlert = UIAlertController(title: "Really quit?" , message: "Resume your game or quit.", preferredStyle: .alert)
    let returnAction = UIAlertAction(title: "Resume", style: .cancel) { action in
      completionHandler(false)
    }
    reallyQuitAlert.addAction(returnAction)
    let quitAction = UIAlertAction(title: "Quit", style: .destructive) { action in
      completionHandler(true)
    }
    reallyQuitAlert.addAction(quitAction)
    present(reallyQuitAlert, animated: true, completion: nil)
  }
  
  func finaliseGame(won: Bool, pegBoardView: PegBoardView) {
    let gameOverAlert = UIAlertController(title: won ? "You won!": "You lost.", message: "Start a new game?", preferredStyle: .alert)
    let viewBoardAction = UIAlertAction(title: "View Board", style: .cancel) { action in
      //print("No action required")
    }
    gameOverAlert.addAction(viewBoardAction)
    let newGameAction = UIAlertAction(title: "New Game", style: .destructive) { action in
      self.restartGame()
    }
    gameOverAlert.addAction(newGameAction)
    present(gameOverAlert, animated: true, completion: nil)
  }
  
  func restartGame() {
    //New Game Logic:
    self.game.initGame()
    //TODO: Make conditional upon if settings need updating:
    updateGeometry()
    self.game.setupCodeAndHoles()
    let pegBoardView = self.pegBoardView!
    pegBoardView.reactivateTurnOne()
    _ = pegBoardView.subviews.filter{$0 is FeedbackView}.map{$0.removeFromSuperview()}
    pegBoardView.addTurnButtons()
    pegBoardView.setNeedsLayout()
    if let memoryVC = memoryVC {
      memoryVC.memView?.resetAll()
    }
  }
  
}
