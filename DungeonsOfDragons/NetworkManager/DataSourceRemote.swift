//
//  DataSourceRemote.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import Foundation

final class DataSourceRemote {
    static let shared = DataSourceRemote()
    
    func getMonsters(completion: @escaping([MonsterModel]) -> ()) {
        guard let url = URL(string: Link.urlMonsters) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data else {
                print("\(#file.components(separatedBy: "/").last ?? "") \(#function) \(#line)\nERROR - \(error?.localizedDescription ?? "")\n")
                return
            }
            
            do {
                let result = try JSONDecoder().decode([MonsterModel].self, from: data)
                DispatchQueue.main.async {
                    completion(result)
                }
            }catch {
                print("\(#file.components(separatedBy: "/").last ?? "") \(#function) \(#line)\nERROR - \(error)\n")
            }
            
        }.resume()
    }
    
    func getSpells(completion: @escaping([SpellModel]) -> ()) {
        guard let url = URL(string: Link.urlSpells) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data else {
                print("\(#file.components(separatedBy: "/").last ?? "") \(#function) \(#line)\nERROR - \(error?.localizedDescription ?? "")\n")
                return
            }
            
            do {
                let result = try JSONDecoder().decode([SpellModel].self, from: data)
                DispatchQueue.main.async {
                    completion(result)
                }
            }catch {
                print("\(#file.components(separatedBy: "/").last ?? "") \(#function) \(#line)\nERROR - \(error)\n")
            }
            
        }.resume()
    }
}
