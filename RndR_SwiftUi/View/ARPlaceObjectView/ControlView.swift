//
//  ControlView.swift
//  ArView
//
//  Created by Prabal Kumar on 08/10/24.
//

import SwiftUI

enum ControlModes: String, CaseIterable{
    case browse, scene
}

struct ControlView: View {
    @Binding var selectedControlMode: Int
    @Binding var isControlsVisible: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    
    
    var body: some View {
        VStack{
            ControlVisibilityButton(isControlsVisible: $isControlsVisible)
            
            Spacer()
            
            if(isControlsVisible){
                ControlModePicker(selectedControlMode: $selectedControlMode)
                ControlButtonBar(showBrowse: $showBrowse, showSettings: $showSettings, selectedControlMode: selectedControlMode)
            }
        }
    }
}

struct ControlVisibilityButton: View {
    
    @Binding var isControlsVisible: Bool
    
    var body: some View {
        HStack{
            
            Spacer()
            
            ZStack{
                
                Color.black.opacity(0.25)
                
                Button{
                    isControlsVisible.toggle()
                }label: {
                    Image(systemName: self.isControlsVisible ? "rectangle" : "slider.horizontal.below.rectangle")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                    
                    
                }
                .padding()
            }
            .cornerRadius(10)
            .frame(width: 45,height: 45)
        }
        .padding(.top,60)
        .padding(.trailing,60)
    }
}

struct ControlModePicker: View {
    @Binding var selectedControlMode: Int
    let controlModes = ControlModes.allCases
    
    init(selectedControlMode: Binding<Int> ) {
        self._selectedControlMode = selectedControlMode
        
        UISegmentedControl.appearance().selectedSegmentTintColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(displayP3Red: 1.0, green: 0.827, blue: 0, alpha: 1)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor:  UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.black.opacity(0.25))
        
    }
    
    var body: some View {
        Picker(selection: $selectedControlMode, label: Text("Select a control modde")){
            ForEach(0..<controlModes.count){ index in
                Text(self.controlModes[index].rawValue.uppercased()).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: 400)
        .padding(.horizontal,10)
    }
}

struct BrowseButtons: View{
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse:Bool
    @Binding var showSettings:Bool
    
    var body: some View {
        HStack{
            
            Spacer()
            
            MostRecentlyPlacementButton()
                .hidden(self.placementSettings.recentlyPlaced.isEmpty)
            
            Spacer()
            
            
            Button{
                self.showBrowse.toggle()
            }label: {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            .sheet(isPresented: $showBrowse){
                BrowseView(showBrowse: $showBrowse)
                    .environmentObject(placementSettings)
            }
            
            Spacer()
            
            Button{
                print("Settings button pressed")
                self.showSettings.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            .sheet(isPresented: $showSettings){
                SettingsView(showSettings: $showSettings)
                //                    .presentationDetents([.fraction(0.3)])
            }
            
            Spacer()
        }
//        .frame(maxWidth: 500,maxHeight: 50)
//        .padding()
//        .background(Color.black.opacity(0.5))
//        .cornerRadius(50)
//        .padding([.horizontal,.bottom])
        //        .padding(.bottom,-20)
        //        .ignoresSafeArea(.all)
    }
}

struct SceneButtons: View {
    @EnvironmentObject var sceneManager: SceneManager
    
    var body: some View {
        
        Spacer()
        
        Button{
            print("Save button pressed")
            self.sceneManager.shouldSaveSceneToFileSystem = true
        } label: {
            Image(systemName: "icloud.and.arrow.up")
                .font(.system(size: 35))
                .foregroundColor(.white)
        }
        .hidden(!self.sceneManager.isPersistenceAvailable)
        
        Spacer()
        
        
        Button{
            print("Load button pressed")
            self.sceneManager.shouldLoadSceneFromFileSystem = true
        } label: {
            Image(systemName: "icloud.and.arrow.down")
                .font(.system(size: 35))
                .foregroundColor(.white)
        }
        .hidden(self.sceneManager.scenePersistenceData == nil )
        
        Spacer()
        
        Button{
            print("Clear button pressed")
            
            for anchorEntity in self.sceneManager.anchorEntities{
                print("Removing anchorEntity with id: \(String(describing: anchorEntity.anchorIdentifier))")
                anchorEntity.removeFromParent()
            }
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 35))
                .foregroundColor(.white)
        }
        
        Spacer()
    }
}

struct ControlButtonBar: View {
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    
    var selectedControlMode: Int
    
    var body: some View {
        HStack(alignment: .center){
            if(selectedControlMode == 1){
                SceneButtons()
            }
            else{
                BrowseButtons(showBrowse: $showBrowse, showSettings: $showSettings)
            }
        }
        .frame(maxWidth: 500,maxHeight: 50)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(50)
                .padding([.horizontal,.bottom])
    }
}

struct MostRecentlyPlacementButton: View {
    
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var body: some View {
        Button{
            print("Most recently placed button pressed")
            
            self.placementSettings.selectedModel = self.placementSettings.recentlyPlaced.last
        } label: {
            if let mostRecentlyPlaced = self.placementSettings.recentlyPlaced.last{
                Image(uiImage: mostRecentlyPlaced.thumbnail)
                    .resizable()
                    .frame(width: 46)
                    .aspectRatio(1/1, contentMode: .fit)
            }
            else{
                Image(systemName: "clock")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 50, height: 50)
        .background(Color.white)
        .cornerRadius(8)
    }
}



//#Preview {
//    ControlView(selectedControlMode: $selectedControlMode, isControlsVisible: .constant(true), showBrowse: .constant(false), showSettings: .constant(false))
//}
