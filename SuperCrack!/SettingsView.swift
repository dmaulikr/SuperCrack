//
//  SettingsView.swift
//  MastermindJune
//
//  Created by Dave Chambers on 23/06/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import SwiftySound
import UIKit
import SnapKit

class SettingsView: UIView {
  
  private let dimensions: GameDimensions
  private var game: GameModel
  private var valueLabels: [UILabel] = Array()
  
  init(frame: CGRect, game: GameModel, dimensions: GameDimensions){
    self.game = game
    self.dimensions = dimensions
    super.init(frame: frame)
    self.backgroundColor = UIColor.black
  }
  
  override func layoutSubviews() {
    _ = self.subviews.map{ $0.removeFromSuperview() }
    valueLabels.removeAll()
    _ = game.getSettings().getSettings().map{setupASetting(setting: $0)}
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding")
  }
  
  func setupASetting(setting: Setting) {
    
    let numSettings = game.getSettings().getSettings().count
    let gap = (CGFloat(numSettings))*dimensions.tileSize/2 //Gaps of half a tile size
    
    let settingHeight:  CGFloat = (dimensions.usableHeight-CGFloat(numSettings)*CGFloat(gap))/CGFloat(numSettings)
    let placedControl:  CGFloat = CGFloat(setting.getPosition()-1) //0,1,2....
    
    let nameLabel: UILabel = UILabel()
    nameLabel.textAlignment = .center
    nameLabel.backgroundColor = setting.getColour()
    nameLabel.text = setting.getName()
    nameLabel.font = UIFont.boldSystemFont(ofSize: dimensions.settingsButtonFontSize)
    nameLabel.textColor = setting.getTextColour()
    self.addSubview(nameLabel)
    nameLabel.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(dimensions.mainAreaWidth)
      make.height.equalTo(settingHeight/3)
      make.centerX.equalTo(self.center.x)
      make.top.equalTo(gap/2+placedControl*(gap+settingHeight))
    }
    
    let slider = UISlider()
    slider.minimumValue = Float(setting.getMin())
    slider.maximumValue = Float(setting.getMax())
    slider.value = Float(setting.getUncommitedValue())
    slider.isContinuous = true
    slider.tintColor = setting.getColour()
    slider.tag = setting.getPosition()
    slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
    self.addSubview(slider)
    slider.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(dimensions.mainAreaWidth)
      make.height.equalTo(settingHeight/3)
      make.centerX.equalTo(self.center.x)
      make.top.equalTo(gap/2+placedControl*(gap+settingHeight)+settingHeight/3)
    }
    
    let valueLabel: UILabel = UILabel()
    valueLabel.textAlignment = .center
    valueLabel.backgroundColor = setting.getColour()
    valueLabel.text = String(setting.getUncommitedValue())
    valueLabel.font = UIFont.boldSystemFont(ofSize: dimensions.settingsButtonFontSize)
    valueLabel.textColor = setting.getTextColour()
    self.addSubview(valueLabel)
    valueLabel.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(dimensions.mainAreaWidth)
      make.height.equalTo(settingHeight/3)
      make.centerX.equalTo(self.center.x)
      make.top.equalTo(gap/2+placedControl*(gap+settingHeight)+2*settingHeight/3)
    }
    valueLabels.append(valueLabel)
  }
  
  func sliderValueDidChange(_ sender:UISlider!)
  {
    //UISlider should snap to values step by step:
    let roundedStepValue = round(sender.value / 1) * 1
    sender.value = roundedStepValue
    let setting = game.getSettings().getSettings()[sender.tag-1]
    let newValue = Int(roundedStepValue)
    if setting.getUncommitedValue() != newValue {
      Sound.play(file: "Turn.wav")
    }
    setting.setUncommitedValue(updatedValue: newValue)
    valueLabels[sender.tag-1].text = String(newValue)
  }
  
}
