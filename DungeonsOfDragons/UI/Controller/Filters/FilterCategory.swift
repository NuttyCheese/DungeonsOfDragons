//
//  FilterCategory.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 12.01.2026.
//

import Foundation

// MARK: - Filter Category Protocol
protocol FilterCategory: Filterable {
    var categoryTitle: String { get }
}

// MARK: - Monster Filter Categories
enum MonsterFilterCategory: FilterCategory, Hashable {
    case biom
    case cha
    case size
    case type
    
    var categoryTitle: String {
        switch self {
        case .biom:
            return "Биом"
        case .cha:
            return "Характеристика"
        case .size:
            return "Размер"
        case .type:
            return "Тип"
        }
    }
    
    var filterDisplayName: String {
        return categoryTitle
    }
}

// MARK: - Monster Filter Value
enum MonsterFilterValue: Filterable, Hashable {
    case biom(Biom)
    case cha(Cha)
    case size(Size)
    case type(TypeEnum)
    
    var filterDisplayName: String {
        switch self {
        case .biom(let biom):
            return biom.rawValue
        case .cha(let cha):
            return cha.rawValue
        case .size(let size):
            return size.rawValue
        case .type(let type):
            return type.rawValue
        }
    }
}

// MARK: - Spell Filter Categories
enum SpellFilterCategory: FilterCategory, Hashable {
    case school
    case spellCaster
    
    var categoryTitle: String {
        switch self {
        case .school:
            return "Школа"
        case .spellCaster:
            return "Класс заклинателя"
        }
    }
    
    var filterDisplayName: String {
        return categoryTitle
    }
}

// MARK: - Spell Filter Value
enum SpellFilterValue: Filterable, Hashable {
    case school(School)
    case spellCaster(SpellCaster)
    
    var filterDisplayName: String {
        switch self {
        case .school(let school):
            return school.rawValue
        case .spellCaster(let caster):
            return caster.rawValue
        }
    }
}


// MARK: - Extension для фильтрации по доступным значениям из моделей
extension Array where Element == MonsterModel {
    func getAvailableFilterValues(for category: MonsterFilterCategory) -> [MonsterFilterValue] {
        switch category {
        case .biom:
            let allBioms = Set(flatMap { $0.bioms })
            return allBioms.map { MonsterFilterValue.biom($0) }
        case .cha:
            // Для Cha нужно собрать все уникальные значения из всех характеристик
            let allChas = Set([map { $0.str }, map { $0.dex }, map { $0.con }, map { $0.intilect }, map { $0.wis }, map { $0.cha }].flatMap { $0 })
            return allChas.map { MonsterFilterValue.cha($0) }
        case .size:
            let allSizes = Set(map { $0.size })
            return allSizes.map { MonsterFilterValue.size($0) }
        case .type:
            let allTypes = Set(map { $0.type })
            return allTypes.map { MonsterFilterValue.type($0) }
        }
    }
}

extension Array where Element == SpellModel {
    func getAvailableFilterValues(for category: SpellFilterCategory) -> [SpellFilterValue] {
        switch category {
        case .school:
            let allSchools = Set(compactMap { $0.school })
            return allSchools.map { SpellFilterValue.school($0) }
        case .spellCaster:
            let allCasters = Set(flatMap { $0.spellClass ?? [] }.compactMap { $0.name })
            return allCasters.map { SpellFilterValue.spellCaster($0) }
        }
    }
}
