//
//  SpellModel.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import Foundation

// MARK: - Spell Model
struct SpellModel: Codable, Hashable {
    let nameEn, name: String
    let school: School?
    let level, castingTime: String?
    let range: String
    let components: String?
    let duration, text: String
    let spellClass: [SpellClass]
}

// MARK: - School
enum School: String, Codable {
    /// Воплощение
    case embodiment = "воплощение"
    /// Вызов
    case conjuration = "вызов"
    /// Иллюзия
    case illusion = "иллюзия"
    /// Некромантия
    case necromancy = "некромантия"
    /// Ограждение
    case abjuration = "ограждение"
    /// Очарование
    case enchantment = "очарование"
    /// Преобразование
    case transmutation = "преобразование"
    /// Прорицание
    case divination = "прорицание"
    /// Магия Пустоты
    case voidMagic = "Магия Пустоты"
    /// Проявление
    case manifestation = "Проявление"
    /// Пустота
    case voidSchool = "Пустота"
    /// Ритуал
    case ritual = "ритуал"
}

// MARK: - Spell Class
struct SpellClass: Codable, Hashable {
    let name: SpellCaster
    let selected: Bool
}

// MARK: - Spell Caster Names
enum SpellCaster: String, Codable {
    /// Бард
    case bard = "Бард"
    /// Волшебник
    case wizard = "Волшебник"
    /// Друид
    case druid = "Друид"
    /// Жрец
    case cleric = "Жрец"
    /// Колдун
    case warlock = "Колдун"
    /// Паладин
    case paladin = "Паладин"
    /// Рейнджер
    case ranger = "Рейнджер"
    /// Чародей
    case sorcerer = "Чародей"
}
