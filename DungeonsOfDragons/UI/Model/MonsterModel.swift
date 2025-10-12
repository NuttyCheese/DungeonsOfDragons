//
//  MonsterModel.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import Foundation

// MARK: - Monster Model
struct MonsterModel: Codable, Hashable {
    let name, pdfName, lineHeight: String
    let fiction, pdfFiction: String?
    let size: Size
    let type: MonsterType
    let alignment, ac, pdfAC, hp: String
    let speed: String
    let str, dex, con, intellect: Cha
    let wis, cha: Cha
    let passive: String
    let languages: [String]
    let cr, exp: String
    let senses: String?
    let skill: [String]
    let monsterTrait, monsterAction: [MonsterActionModel]
    let bioms: [Biom]
    let imgStaticURL: String

    enum CodingKeys: String, CodingKey {
        case name, pdfName, lineHeight, fiction, pdfFiction, size, type, alignment, ac
        case pdfAC = "pdfAc"
        case hp, speed, str, dex, con, wis, cha, passive, languages, cr, exp, senses, skill, monsterTrait, monsterAction, bioms
        case imgStaticURL = "imgStaticUrl"
        case intellect = "intilect"
    }
}

// MARK: - Monster Action Model
struct MonsterActionModel: Codable, Hashable {
    let id: Int
    let name, text: String
    let attack: String?
}

// MARK: - Biomes
enum Biom: String, Codable {
    /// Болота
    case swamps = "Болота"
    /// Все
    case all = "Все"
    /// Город
    case city = "Город"
    /// Горы
    case mountains = "Горы"
    /// Заполярье
    case polar = "Заполярье"
    /// Лес
    case forest = "Лес"
    /// Побережье
    case coast = "Побережье"
    /// Подземье
    case underground = "Подземье"
    /// Пустыня
    case desert = "Пустыня"
    /// Равнина
    case plains = "Равнина"
    /// Холмы
    case hills = "Холмы"
}

// MARK: - Ability Scores
enum Cha: String, Codable {
    /// 10 (0)
    case ten0 = "10(0)"
    /// 11 (0)
    case eleven0 = "11(0)"
    /// 12 (+1)
    case twelve1 = "12(1)"
    /// 13 (+1)
    case thirteen1 = "13(1)"
    /// 14 (+2)
    case fourteen2 = "14(2)"
    /// 1 (-5)
    case oneMinus5 = "1(-5)"
    /// 15 (+2)
    case fifteen2 = "15(2)"
    /// 16 (+3)
    case sixteen3 = "16(3)"
    /// 17 (+3)
    case seventeen3 = "17(3)"
    /// 18 (+4)
    case eighteen4 = "18(4)"
    /// 19 (+4)
    case nineteen4 = "19(4)"
    /// 20 (+5)
    case twenty5 = "20(5)"
    /// 21 (+5)
    case twentyOne5 = "21(5)"
    /// 22 (+6)
    case twentyTwo6 = "22(6)"
    /// 23 (+6)
    case twentyThree6 = "23(6)"
    /// 2 (-4)
    case twoMinus4 = "2(-4)"
    /// 24 (+7)
    case twentyFour7 = "24(7)"
    /// 25 (+7)
    case twentyFive7 = "25(7)"
    /// 26 (+8)
    case twentySix8 = "26(8)"
    /// 27 (+8)
    case twentySeven8 = "27(8)"
    /// 28 (+9)
    case twentyEight9 = "28(9)"
    /// 29 (+9)
    case twentyNine9 = "29(9)"
    /// 30 (+10)
    case thirty10 = "30(10)"
    /// 3 (-4)
    case threeMinus4 = "3(-4)"
    /// 4 (-3)
    case fourMinus3 = "4(-3)"
    /// 5 (-3)
    case fiveMinus3 = "5(-3)"
    /// 6 (-2)
    case sixMinus2 = "6(-2)"
    /// 7 (-2)
    case sevenMinus2 = "7(-2)"
    /// 8 (-1)
    case eightMinus1 = "8(-1)"
    /// 9 (-1)
    case nineMinus1 = "9(-1)"
}

// MARK: - Monster Size
enum Size: String, Codable {
    /// Большой
    case large = "Большой"
    /// Колоссальный
    case colossal = "Колоссальный"
    /// Крошечный
    case tiny = "Крошечный"
    /// Маленький
    case small = "Маленький"
    /// Огромный
    case huge = "Огромный"
    /// Средний
    case medium = "Средний"
}

// MARK: - Monster Type
enum MonsterType: String, Codable {
    /// Аберрация
    case aberration = "аберрация"
    /// Великан
    case giant = "великан"
    /// Гуманоид
    case humanoid = "гуманоид"
    /// Демон
    case demon = "демон"
    /// Дракон
    case dragon = "дракон"
    /// Зверь
    case beast = "зверь"
    /// Исчадие
    case spawn = "исчадие"
    /// Конструкт
    case construct = "конструкт"
    /// Монстр
    case monster = "монстр"
    /// Небожитель
    case celestial = "небожитель"
    /// Нежить
    case undead = "нежить"
    /// Растение
    case plant = "растение"
    /// Рой крошечных зверей
    case swarmOfTinyBeasts = "рой крошечных зверей"
    /// Слизь
    case ooze = "слизь"
    /// Фея
    case fairy = "фея"
    /// Элементаль
    case elemental = "элементаль"
}

