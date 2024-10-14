//
//  ARViewContainer.swift
//  RndR_SwiftUi
//
//  Created by Prabal Kumar on 13/10/24.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit

private let anchorNamePrefix = "model-"

struct ARViewContainerdemo: UIViewRepresentable{
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelsViewModel: ModelViewModel
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    
    func makeUIView(context: Context) -> CustomARView {
        
        let arView = CustomARView(frame: .zero,sessionSettings: sessionSettings, modelDeletionManager: modelDeletionManager)
        
        arView.session.delegate = context.coordinator
        
        //add subscriber
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            
            self.updateScene(for: arView)
            //call update scene method
            self.updatePersistenceAvaibility(for: arView)
            
            self.handlePersistence(for: arView)
            
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView){
        // display focus entity logic
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        if let modelAnchor = self.placementSettings.modelsConfirmedForPlacement.popLast(), let modelEntity = modelAnchor.model.modelEntity{
            if let anchor = modelAnchor.anchor{
                self.place(modelEntity, for: anchor, in: arView)
            }else if let transform = getTransformForPlacement(in: arView){
                let anchorName = anchorNamePrefix + modelAnchor.model.name
                let anchor = ARAnchor(name: anchorName, transform: transform)
                
                self.place(modelEntity, for: anchor, in: arView)
                
                self.placementSettings.recentlyPlaced.append(modelAnchor.model)
                
            }
        }
    }
    
    private func place(_ modelEntity: ModelEntity, for anchor: ARAnchor, in arView: ARView){
        //clone model entity. this cretes n identical copy of modelEntity and refrences the same model. this also allows us to have multiple models of the same asset in out scene
        let clonedEntity = modelEntity.clone(recursive: true)
        
        //Enable translation and rotation gestures.
        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: clonedEntity)
        
        // Create an anchor Entity and add clonedEntity to the anchorEntity
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        anchorEntity.anchoring = AnchoringComponent(anchor)
        
        // Add the anchor Entity to the arView.scene
        arView.scene.addAnchor(anchorEntity)
        
        self.sceneManager.anchorEntities.append(anchorEntity)
        
        print("Added Entity model to scene")
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .any)
            else{
            return nil
        }
        guard let raycastResult = arView.session.raycast(query).first else { return nil }
        
        return raycastResult.worldTransform
    }
}

class SceneManager: ObservableObject {
    @Published var isPersistenceAvailable: Bool = false
    @Published var anchorEntities: [AnchorEntity] = []
    
    var shouldSaveSceneToFileSystem: Bool = false
    var shouldLoadSceneFromFileSystem: Bool = false
    
    lazy var persistenceUrl: URL = {
        do  {
            return try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("arf.persistence")
        }
        catch {
            fatalError("Unable to get persistenceUrl: \(error.localizedDescription)")
        }
    }()
    
    var scenePersistenceData: Data?{
        return try? Data(contentsOf: persistenceUrl)
    }
    
}

extension ARViewContainerdemo {
    private func updatePersistenceAvaibility(for arView: ARView){
        guard let currentFrame = arView.session.currentFrame else {
            print("ARFrame not available")
            return
        }
        
        switch currentFrame.worldMappingStatus {
        case .mapped, .extending:
            self.sceneManager.isPersistenceAvailable = !self.sceneManager.anchorEntities.isEmpty
        default:
            self.sceneManager.isPersistenceAvailable = false
        }
    }
    
    private func handlePersistence(for arView: CustomARView){
        if self.sceneManager.shouldSaveSceneToFileSystem {
            ScenePersistenceHelper.saveScene(for: arView, at: self.sceneManager.persistenceUrl)
            
            self.sceneManager.shouldSaveSceneToFileSystem = false
        } else if self.sceneManager.shouldLoadSceneFromFileSystem {
            
            guard let scenePersistenceData = self.sceneManager.scenePersistenceData else {
                print("Unable to retieve scenePersistenceData. Canceled loadScene operation")
                
                self.sceneManager.shouldLoadSceneFromFileSystem = false
                
                return
            }
            
            self.modelsViewModel.clearModelEntitiesFromMemory()
            
            self.sceneManager.anchorEntities.removeAll(keepingCapacity: true)
            
            ScenePersistenceHelper.loadScene(for: arView, with: scenePersistenceData)
            
            self.sceneManager.shouldLoadSceneFromFileSystem = false
        }
    }
    
}

//MARK: - ARSessionDelegate + Coordinator

extension ARViewContainerdemo {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainerdemo
        
        init(_ parent: ARViewContainerdemo){
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors{
                if let anchorName = anchor.name, anchorName.hasPrefix(anchorNamePrefix){
                    let modelName = anchorName.dropFirst(anchorNamePrefix.count)
                    
                    print("ARSession: didAdd anchor for modelName: \(modelName)")
                    
                    guard let model = self.parent.modelsViewModel.models.first(where: { $0.name == modelName})
                    else {
                        print("Unable to retrieve model from modelsViewModel.")
                        return
                    }
                    
                    if model.modelEntity == nil{
                        model.asyncLoadModeEntity { completed, error in
                            if completed{
                                let modelAnchor = ModelAnchor(model: model, anchor: anchor)
                                self.parent.placementSettings.modelsConfirmedForPlacement.append(modelAnchor)
                                print("Adding modelAnchor with name: \(model.name)")
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
