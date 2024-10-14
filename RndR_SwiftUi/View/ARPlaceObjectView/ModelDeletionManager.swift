//
//  ModelDeletionManager.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 14/10/24.
//

import SwiftUI
import RealityKit

class ModelDeletionManager: ObservableObject {
    @Published var entitySelectedForDeletion: ModelEntity? = nil{
        willSet(newValue){
            if self.entitySelectedForDeletion == nil, let newSelectedModelEntity = newValue{
                print("Selecting new entitySelectedForDeletion, no prior selection.")
                
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newSelectedModelEntity.modelDebugOptions = component
                
            }else if let previousSelectedModelEntity = self.entitySelectedForDeletion, let newlySelectedModelEntity = newValue{
                print("Selecting new entitySelectedForDeletion, had a prior selection.")
                
                previousSelectedModelEntity.modelDebugOptions = nil
                
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            }else if newValue == nil {
                print("Clearing entitySelectedForDeletion. ")
                
                self.entitySelectedForDeletion?.modelDebugOptions = nil
            }
            
        }
    }
}

