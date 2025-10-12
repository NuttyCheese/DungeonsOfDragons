//
//  Images.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

enum Images: String {
    //MARK: - Images
    case monsters = "img_monster"
    case spells = "img_spell"
    case dice = "img_dice"
    case settings = "img_settings"
    case favorites = "img_favorites"
    case icDnD = "ic_DND"
    
    case notPhoto = "questionmark.circle"
    
    var image: UIImage? {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return UIImage(systemName: "person")
        }
    }
}
