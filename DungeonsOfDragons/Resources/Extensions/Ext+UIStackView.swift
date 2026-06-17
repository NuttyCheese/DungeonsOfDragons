//
//  Ext+UIStackView.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

extension UIStackView {
    func subviewsOnStackView(_ subviews: UIView...) {
        subviews.forEach { addArrangedSubview($0) }
    }
}
