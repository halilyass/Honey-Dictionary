//
//  ConfigureKeyboard.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 9.01.2023.
//

import Foundation
import UIKit


extension UIView {
    
    func keyboardConfigure() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(_ :)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
    @objc private func handleKeyboard(_ notification : NSNotification) {
        
        let time = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        let startFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let finishFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let distance = finishFrame.origin.y - startFrame.origin.y
        
        UIView.animateKeyframes(withDuration: time, delay: 0.0, options: .init(rawValue: curve) ,animations: {
            
            self.frame.origin.y += distance
            
        },completion: nil)
    }
}
