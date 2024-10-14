//
//  SwiftUIView.swift
//  ArView
//
//  Created by Prabal Kumar on 09/10/24.
//

import SwiftUI

enum Setting {
    case peopleOcclusion
    case objectOcclusion
    case lidarDebug
    case multiuser
    
    var label: String {
        get {
            switch self{
                case .peopleOcclusion, .objectOcclusion:
                return "Occlusion"
            
                case .lidarDebug:
                return "LiDAR"
                
            case .multiuser:
                return "Multiuser"
                
            }
        }
    }
    
    var systemIconName: String {
        get {
            switch self{
            case .peopleOcclusion:
                return "person"
                
            case .objectOcclusion:
                return "cube.box.fill"
                
            case .lidarDebug:
                return "light.min"
                
            case .multiuser:
                return "person.2"
                
            }
        }
    }
}

struct SettingsView: View {
    
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationView {
            VStack{
                SettingsGrid()
                    
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.showSettings.toggle()
            }) {
                Text("Done")
            })
        }
    }
}

struct SettingsGrid: View {
    @EnvironmentObject var sessionSettings: SessionSettings
    
    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 25)]
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns, spacing: 25){
                
                SettingsToggleButton(isOn: $sessionSettings.isPeopleOcclusionEnabled, setting: .peopleOcclusion)
                
                SettingsToggleButton(isOn: $sessionSettings.isObjectOcclusionEnabled, setting: .objectOcclusion)
                
                SettingsToggleButton(isOn: $sessionSettings.isLidarDebugEnabled, setting: .lidarDebug)
                
                SettingsToggleButton(isOn: $sessionSettings.isMultiUserEnabled, setting: .multiuser)
            }
            .padding(.top,35)
        }
    }
}



struct SettingsToggleButton: View {
    @Binding var isOn: Bool
    let setting: Setting
    
    var body: some View {
        Button{
            self.isOn.toggle()
            print("\(#file) - \(setting): \(self.isOn)")
        } label: {
            VStack(spacing:10){
                Image(systemName: setting.systemIconName)
                    .font(.system(size:35))
                    .frame(width: 36,height: 36)
                    .foregroundColor(self.isOn ? .green : Color(UIColor.secondaryLabel))
                
                Text(setting.label)
                    .font(.system(size:17, weight: .medium, design: .default))
                    .foregroundColor(self.isOn ? .green : Color(UIColor.secondaryLabel))
                    .padding(.top,5)
            }
        }
        .frame(width: 100,height: 100)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20)
    }
}

#Preview {
    SettingsGrid()
}
