//
//  FilterSection.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import Foundation

// MARK: - Filterable Protocol
protocol Filterable: Hashable {
    var filterDisplayName: String { get }
}

// MARK: - Section Enum
enum FilterSection: Int, CaseIterable, Hashable {
    case selected = 0
    case categories = 1
    
    var title: String {
        switch self {
        case .selected:
            return "Выбранные фильтры"
        case .categories:
            return "Категории фильтров"
        }
    }
}
