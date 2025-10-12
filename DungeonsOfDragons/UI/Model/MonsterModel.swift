//
//  MonsterModel.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import Foundation

struct MonsterModel: Codable, Hashable {
    let name, pdfName, lineHeight: String
    let fiction, pdfFiction: String?
    let size: Size
    let type: TypeEnum
    let alignment, ac, pdfAC, hp: String
    let speed: String
    let str, dex, con, intilect: Cha
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
        case hp, speed, str, dex, con, intilect, wis, cha, passive, languages, cr, exp, senses, skill, monsterTrait, monsterAction, bioms
        case imgStaticURL = "imgStaticUrl"
    }
}

enum Biom: String, Codable {
    case болота = "Болота"
    case все = "Все"
    case город = "Город"
    case горы = "Горы"
    case заполярье = "Заполярье"
    case лес = "Лес"
    case побережье = "Побережье"
    case подземье = "Подземье"
    case пустыня = "Пустыня"
    case равнина = "Равнина"
    case холмы = "Холмы"
}

enum Cha: String, Codable {
    case the100 = "10(0)"
    case the110 = "11(0)"
    case the121 = "12(1)"
    case the131 = "13(1)"
    case the142 = "14(2)"
    case the15 = "1(-5)"
    case the152 = "15(2)"
    case the163 = "16(3)"
    case the173 = "17(3)"
    case the184 = "18(4)"
    case the194 = "19(4)"
    case the205 = "20(5)"
    case the215 = "21(5)"
    case the226 = "22(6)"
    case the236 = "23(6)"
    case the24 = "2(-4)"
    case the247 = "24(7)"
    case the257 = "25(7)"
    case the268 = "26(8)"
    case the278 = "27(8)"
    case the289 = "28(9)"
    case the299 = "29(9)"
    case the3010 = "30(10)"
    case the34 = "3(-4)"
    case the43 = "4(-3)"
    case the53 = "5(-3)"
    case the62 = "6(-2)"
    case the72 = "7(-2)"
    case the81 = "8(-1)"
    case the91 = "9(-1)"
}

// MARK: - MonsterActionModel
struct MonsterActionModel: Codable, Hashable {
    let id: Int
    let name, text: String
    let attack: String?
}

enum Size: String, Codable {
    case большой = "Большой"
    case колоссальный = "Колоссальный"
    case крошечный = "Крошечный"
    case маленький = "Маленький"
    case огромный = "Огромный"
    case средний = "Средний"
}

enum TypeEnum: String, Codable {
    case аберрация = "аберрация"
    case великан = "великан"
    case гуманоид = "гуманоид"
    case демон = "демон"
    case дракон = "дракон"
    case зверь = "зверь"
    case исчадие = "исчадие"
    case конструкт = "конструкт"
    case монстр = "монстр"
    case небожитель = "небожитель"
    case нежить = "нежить"
    case растение = "растение"
    case ройКрошечныхЗверей = "рой крошечных зверей"
    case слизь = "слизь"
    case фея = "фея"
    case элементаль = "элементаль"
}


