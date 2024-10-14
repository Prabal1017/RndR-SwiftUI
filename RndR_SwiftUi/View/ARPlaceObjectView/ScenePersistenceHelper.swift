//
//  ScenePersistenceHelper.swift
//  RndR_SwiftUi
//
//  Created by Prabal Kumar on 13/10/24.
//

import Foundation
import RealityKit
import ARKit

class ScenePersistenceHelper{
    class func saveScene(for arView: CustomARView, at persistenceUrl: URL){
        print("Save scene to local storage")
        
        arView.session.getCurrentWorldMap { worldMap, error in
                
            guard let map = worldMap else {
                print("Persistence Error: Unable to get worldMap: \(error!.localizedDescription)")
                return
            }
            
            do {
                let sceneData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                
                try sceneData.write(to: persistenceUrl, options: [.atomic])
            }
            catch {
            print("Persistence Error: Can't save scene to local filesystem: \(error.localizedDescription)")
            }
        }
    }
    
    class func loadScene(for arView: CustomARView, with scenePersistenceData: Data){
        print("Load scene from local storage")
        
        let worldMop: ARWorldMap = {
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: scenePersistenceData) else {
                    fatalError("Presistence Error: No ARWorldMap in archive.")
                }
                
                return worldMap
            }catch{
                fatalError("Presistence Error: Unable to unarchive ARWorldMap from scenePersistenceData: \(error.localizedDescription)")
            }
        }()
        
        let newConfig = arView.defaultConfiguration
        newConfig.initialWorldMap = worldMop
        arView.session.run(newConfig, options: [.resetTracking, .removeExistingAnchors])
    }
}
