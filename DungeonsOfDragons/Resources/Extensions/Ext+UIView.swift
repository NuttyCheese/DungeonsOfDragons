//
//  Ext+UIView.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

extension UIView {
    func tAMIC() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func subviewsOnView(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
    
    func enable() {
        isUserInteractionEnabled = true
    }
    
    func disable() {
        isUserInteractionEnabled = false
    }
}
