//
//  helperFunc.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 08/12/22.
//

import Foundation

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat.random(in: 0...1)  * (max - min) + min
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
