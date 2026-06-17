//
//  SpellModel.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import Foundation

struct SpellModel: Codable, Hashable {
    let nameEn, name: String?
    let school: String?
    let level, castingTime: String?
    let range: String?
    let components: String?
    let duration, text: String?
    let spellClass: [SpellClass]?
}

enum School: String, Codable {
    case schoolВоплощение = "воплощение"
    case schoolВызов = "вызов"
    case schoolИллюзия = "иллюзия"
    case schoolНекромантия = "некромантия"
    case schoolОграждение = "ограждение"
    case schoolОчарование = "очарование"
    case schoolПреобразование = "преобразование"
    case schoolПрорицание = "прорицание"
    case воплощение = "Воплощение"
    case вызов = "Вызов"
    case иллюзия = "Иллюзия"
    case магияПустоты = "Магия Пустоты"
    case некромантия = "Некромантия"
    case ограждение = "Ограждение"
    case очарование = "Очарование"
    case преобразование = "Преобразование"
    case прорицание = "Прорицание"
    case проявление = "Проявление"
    case пустота = "Пустота"
    case ритуал = "ритуал"
}

struct SpellClass: Codable, Hashable {
    let name: String?
    let selected: Bool?
}

enum SpellCaster: String, Codable {
    case бард = "Бард"
    case волшебник = "Волшебник"
    case друид = "Друид"
    case жрец = "Жрец"
    case колдун = "Колдун"
    case паладин = "Паладин"
    case рейнджер = "Рейнджер"
    case чародей = "Чародей"
}
