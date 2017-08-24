//
//  ShowOnlyTicksButton.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 27/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


class ShowOnlyTicksButton: UIButton {
  
  private var showingOnlyTicks: Bool
  
  func isShowingOnlyTicks() -> Bool {
    return showingOnlyTicks
  }
  
  func setShowingOnlyTicks(showingOnly: Bool) {
    showingOnlyTicks = showingOnly
  }
  
  required init() {
    self.showingOnlyTicks = false
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
