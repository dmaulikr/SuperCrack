//
//  Extensions.swift
//  Pegs in the Head
//
//  Created by Dave Chambers on 04/07/2017.
//  Copyright © 2017 Dave Chambers. All rights reserved.
//

import UIKit


extension CGPoint: Hashable {
  public var hashValue: Int {
    return hash()
  }
  
  func hash() -> Int {
    var hash = 23
    hash = hash &* 31 &+ Int(self.x)
    return hash &* 31 &+ Int(self.y)
  }
}

extension UIColor {
  static var greenPeg: UIColor  { return UIColor(red: 6/255, green: 185/255, blue: 56/255, alpha: 1) }
  static var orangePeg: UIColor  { return UIColor(red: 255/255, green: 167/255, blue: 0/255, alpha: 1) }
  static var purplePeg: UIColor  { return UIColor(red: 204/255, green: 51/255, blue: 255/255, alpha: 1) }
  static var bluePeg: UIColor  { return UIColor(red: 0/255, green: 135/255, blue: 252/255, alpha: 1) }
}

extension UIView {
  var parentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}

extension UIView {
  
  func imageSnapshot() -> UIImage {
    return self.imageSnapshotCroppedToFrame(frame: nil)
  }
  
  func imageSnapshotCroppedToFrame(frame: CGRect?) -> UIImage {
    let scaleFactor = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, scaleFactor)
    self.drawHierarchy(in: bounds, afterScreenUpdates: true)
    var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    if let frame = frame {
      // UIImages are measured in points, but CGImages are measured in pixels
      let scaledRect = frame.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
      
      if let imageRef = image.cgImage!.cropping(to: scaledRect) {
        image = UIImage(cgImage: imageRef)
      }
    }
    return image
  }
}

extension Array where Element: Equatable {
  
  // Remove first collection element that is equal to the given `object`:
  mutating func remove(object: Element) {
    if let index = index(of: object) {
      remove(at: index)
    }
  }
}
