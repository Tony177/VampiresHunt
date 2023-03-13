//
//  SettingsView.swift
//  Vampire's Hunt
//
//  Created by Antonio Avolio on 13/03/23.
//

import SwiftUI

struct SettingsView: View {
    @State var audioSFXState : Float = audioSFX
    @State var audioMusicState : Float = audioMusic
    var body: some View {
        NavigationStack{
            
            HStack{
                Text(LocalizedStringKey("sfx"))
                Text(audioSFXState.formatted(.number))
            }
            Slider(value:$audioSFXState,in: 0...1.0,step:0.1)
            {
                Text("Audio Effect")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("1")
            }.tint(.customRed)
            Spacer().frame(height: 60)
            HStack{
                Text(LocalizedStringKey("music"))
                Text(audioMusicState.formatted(.number))
            }
            Slider(value:$audioMusicState,in: 0...1.0,step:0.1)
            {
                Text("Background Music")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("1")
            }.tint(.customRed)
            
        }.font(.custom("CasaleTwo NBP", size: 22))
        .padding()
            .onDisappear(){
                UserDefaults.standard.set(audioSFXState, forKey: "audioSFX")
                UserDefaults.standard.set(audioMusicState, forKey: "audioMusic")
                audioSFX = audioSFXState
                audioMusic = audioMusicState
            }
    }
}
struct CustomToggleStyle : ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Text("CIAO")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
