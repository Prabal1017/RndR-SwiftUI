//
//  PlacementSettings.swift
//  ArView
//
//  Created by Prabal Kumar on 08/10/24.
//

import SwiftUI
import RealityKit
import Combine
import ARKit

struct ModelAnchor{
    var model: Model
    var anchor: ARAnchor?
}

class PlacementSettings: ObservableObject {
    
    //When user selects a model in browswerView, this property is set
    @Published var selectedModel: Model? {
        willSet(newValue){
            print("Settings selectedModel to \(String(describing: newValue?.name))")
        }
    }
    
    var modelsConfirmedForPlacement: [ModelAnchor] = []
    
    @Published var recentlyPlaced: [Model] = []
    
    var sceneObserver: Cancellable?
}
