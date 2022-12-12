//
//  Struct.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 07/12/22.
//

import Foundation

/*struct PhysicsCategory {
    static let none         : UInt32 = 0
    static let player       : UInt32 = 0b1       // 1
    static let projectile   : UInt32 = 0b10      // 2
    static let coin         : UInt32 = 0b100     // 4
    static let all          : UInt32 = UInt32.max
}

struct Layer{
    static let layer1 : CGFloat = 1.0
    static let layer2 : CGFloat = 2.0
}
*/

struct Leaderboard : Sequence,Codable {
    var records : [Record]
    
    func copyAddRecord(record : Record) -> Leaderboard{
        var t : Leaderboard = self
        t.records.append(record)
        t.records.sort { $0.score >= $1.score}
        t.records.removeLast()
        return t
    }
    init(){
        self.records = []
        for i in (1..<11).reversed(){
            self.records.append(Record(name: "Game", score: i*100))
        }
    }
    func makeIterator() -> LeaderboardIterator {
        return Iterator(leaderboard: self)
    }
}

struct Record : Sequence,Codable{
    
    var name : String
    var score : Int
    init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
    func makeIterator() -> RecordIterator {
        return Iterator(record: self)
    }
    
}

struct RecordIterator: IteratorProtocol {
    
    let record : Record
    mutating func next() -> Record? {
        return record
    }
}

struct LeaderboardIterator: IteratorProtocol {
    
    let leaderboard : Leaderboard
    mutating func next() -> Leaderboard? {
        return leaderboard
    }
}

func decodeLeaderboard(userDefaultsKey: String) -> Leaderboard{
    if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
        do {
            let lead = try JSONDecoder().decode(Leaderboard.self, from: data)
            return lead
        } catch {
            print("Unable to Decode Note (\(error))")
        }
    } else {
        return Leaderboard()
    }
    return Leaderboard()
}

func encodeLeaderboard(userDefaultsKey : String,leaderboard : Leaderboard){
    do{
        let t = try JSONEncoder().encode(leaderboard)
        UserDefaults.standard.setValue(t, forKey: userDefaultsKey)
    }catch{
        print("Error encode: \(error)")
    }
}
