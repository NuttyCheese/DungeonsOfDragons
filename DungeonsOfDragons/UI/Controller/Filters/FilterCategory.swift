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
    case skill
    case exp
    case cr
    case ac
    case hp
    case speed
    case alignment
    case str
    case dex
    case con
    case intilect
    case wis
    case chaStat
    
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
        case .skill:
            return "Навык"
        case .exp:
            return "Опыт"
        case .cr:
            return "Рейтинг сложности"
        case .ac:
            return "Класс брони"
        case .hp:
            return "Здоровье"
        case .speed:
            return "Скорость"
        case .alignment:
            return "Мировоззрение"
        case .str:
            return "Сила"
        case .dex:
            return "Ловкость"
        case .con:
            return "Телосложение"
        case .intilect:
            return "Интеллект"
        case .wis:
            return "Мудрость"
        case .chaStat:
            return "Харизма"
        }
    }
    
    var filterDisplayName: String {
        return categoryTitle
    }
}

// MARK: - Monster Filter Value
enum MonsterFilterValue: Filterable, Hashable {
    case biom(String)
    case cha(String)
    case size(String)
    case type(String)
    case skill(String)
    case exp(String)
    case cr(String)
    case ac(String)
    case hp(String)
    case speed(String)
    case alignment(String)
    case str(String)
    case dex(String)
    case con(String)
    case intilect(String)
    case wis(String)
    case chaStat(String)
    
    var filterDisplayName: String {
        switch self {
        case .biom(let biom):
            return biom
        case .cha(let cha):
            return cha
        case .size(let size):
            return size
        case .type(let type):
            return type
        case .skill(let skill):
            return skill
        case .exp(let exp):
            return exp
        case .cr(let cr):
            return cr
        case .ac(let ac):
            return ac
        case .hp(let hp):
            return hp
        case .speed(let speed):
            return speed
        case .alignment(let alignment):
            return alignment
        case .str(let str):
            return str
        case .dex(let dex):
            return dex
        case .con(let con):
            return con
        case .intilect(let intilect):
            return intilect
        case .wis(let wis):
            return wis
        case .chaStat(let chaStat):
            return chaStat
        }
    }
}

// MARK: - Spell Filter Categories
enum SpellFilterCategory: FilterCategory, Hashable {
    case school
    case spellCaster
    case components
    case range
    case castingTime
    case duration
    case level
    
    var categoryTitle: String {
        switch self {
        case .school:
            return "Школа"
        case .spellCaster:
            return "Класс заклинателя"
        case .components:
            return "Компоненты"
        case .range:
            return "Расстояние"
        case .castingTime:
            return "Время действия"
        case .duration:
            return "Длительность"
        case .level:
            return "Уровень"
        }
    }
    
    var filterDisplayName: String {
        return categoryTitle
    }
}

// MARK: - Spell Filter Value
enum SpellFilterValue: Filterable, Hashable {
    case school(String)
    case spellCaster(String)
    case components(String)
    case range(String)
    case castingTime(String)
    case duration(String)
    case level(String)
    
    var filterDisplayName: String {
        switch self {
        case .school(let school):
            return school
        case .spellCaster(let caster):
            return caster
        case .components(let components):
            return components
        case .range(let range):
            return range
        case .castingTime(let castingTime):
            return castingTime
        case .duration(let duration):
            return duration
        case .level(let level):
            return level
        }
    }
}


// MARK: - Extension для фильтрации по доступным значениям из моделей
extension Array where Element == MonsterModel {
    func getAvailableFilterValues(for category: MonsterFilterCategory) -> [MonsterFilterValue] {
        switch category {
        case .biom:
            let allBioms = Set(flatMap { $0.bioms })
            return allBioms.sorted().map { MonsterFilterValue.biom($0) }
        case .cha:
            // Для Cha нужно собрать все уникальные значения из всех характеристик
            let allChas = Set([map { $0.str }, map { $0.dex }, map { $0.con }, map { $0.intilect }, map { $0.wis }, map { $0.cha }].flatMap { $0 })
            return allChas.sorted().map { MonsterFilterValue.cha($0) }
        case .size:
            let allSizes = Set(map { $0.size })
            return allSizes.sorted().map { MonsterFilterValue.size($0) }
        case .type:
            let allTypes = Set(map { $0.type })
            return allTypes.sorted().map { MonsterFilterValue.type($0) }
        case .skill:
            let allSkills = Set(flatMap { $0.skill })
            return allSkills.sorted().map { MonsterFilterValue.skill($0) }
        case .exp:
            let allExps = Set(map { $0.exp })
            return allExps.sorted().map { MonsterFilterValue.exp($0) }
        case .cr:
            let allCrs = Set(map { $0.cr })
            return allCrs.sorted().map { MonsterFilterValue.cr($0) }
        case .ac:
            let allAcs = Set(map { $0.ac })
            return allAcs.sorted().map { MonsterFilterValue.ac($0) }
        case .hp:
            let allHps = Set(map { $0.hp })
            return allHps.sorted().map { MonsterFilterValue.hp($0) }
        case .speed:
            let allSpeeds = Set(map { $0.speed })
            return allSpeeds.sorted().map { MonsterFilterValue.speed($0) }
        case .alignment:
            let allAlignments = Set(map { $0.alignment })
            return allAlignments.sorted().map { MonsterFilterValue.alignment($0) }
        case .str:
            let allStrs = Set(map { $0.str })
            return allStrs.sorted().map { MonsterFilterValue.str($0) }
        case .dex:
            let allDexs = Set(map { $0.dex })
            return allDexs.sorted().map { MonsterFilterValue.dex($0) }
        case .con:
            let allCons = Set(map { $0.con })
            return allCons.sorted().map { MonsterFilterValue.con($0) }
        case .intilect:
            let allIntilects = Set(map { $0.intilect })
            return allIntilects.sorted().map { MonsterFilterValue.intilect($0) }
        case .wis:
            let allWises = Set(map { $0.wis })
            return allWises.sorted().map { MonsterFilterValue.wis($0) }
        case .chaStat:
            let allChaStats = Set(map { $0.cha })
            return allChaStats.sorted().map { MonsterFilterValue.chaStat($0) }
        }
    }
}

extension Array where Element == SpellModel {
    func getAvailableFilterValues(for category: SpellFilterCategory) -> [SpellFilterValue] {
        switch category {
        case .school:
            let allSchools = Set(compactMap { $0.school })
            return allSchools.sorted().map { SpellFilterValue.school($0) }
        case .spellCaster:
            let allCasters = Set(flatMap { $0.spellClass ?? [] }.compactMap { $0.name })
            return allCasters.sorted().map { SpellFilterValue.spellCaster($0) }
        case .components:
            let allComponents = Set(compactMap { $0.components })
            return allComponents.sorted().map { SpellFilterValue.components($0) }
        case .range:
            let allRanges = Set(compactMap { $0.range })
            return allRanges.sorted().map { SpellFilterValue.range($0) }
        case .castingTime:
            let allCastingTimes = Set(compactMap { $0.castingTime })
            return allCastingTimes.sorted().map { SpellFilterValue.castingTime($0) }
        case .duration:
            let allDurations = Set(compactMap { $0.duration })
            return allDurations.sorted().map { SpellFilterValue.duration($0) }
        case .level:
            let allLevels = Set(compactMap { $0.level })
            return allLevels.sorted().map { SpellFilterValue.level($0) }
        }
    }
}
