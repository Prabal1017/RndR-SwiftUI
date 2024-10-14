//
//  CustonArVIew.swift
//  ArView
//
//  Created by Prabal Kumar on 08/10/24.
//

import RealityKit
import ARKit
import FocusEntity
import SwiftUI
import Combine

class CustomARView: ARView {
    var focusEntity: FocusEntity?
    var sessionSettings: SessionSettings
    var modelDeletionManager: ModelDeletionManager?
    
    var defaultConfiguration: ARWorldTrackingConfiguration{
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            config.sceneReconstruction = .mesh
        }
        
        return config
    }
    
    private var peopleOcclusionCancellable: AnyCancellable?
    private var objectOcclusionCancellable: AnyCancellable?
    private var lidarDebugCancellable: AnyCancellable?
    private var multiuserCancellable: AnyCancellable?
    
    required init(frame frameRect: CGRect, sessionSettings: SessionSettings, modelDeletionManager: ModelDeletionManager) {
        self.sessionSettings = sessionSettings
        self.modelDeletionManager = modelDeletionManager
        
        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
        
        configure()
        
        self.initializeSettings()
        
        self.setupSubscribers()
        
        self.enableObjectDeletion()
        
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        
        
        session.run(defaultConfiguration)
    }
    
    private func setupSubscribers(){
        self.peopleOcclusionCancellable = sessionSettings.$isPeopleOcclusionEnabled.sink{ [weak self] isEnabled in
            self?.updatePeopleOcclusion(isEnabled: isEnabled)
        }
        
        self.objectOcclusionCancellable = sessionSettings.$isObjectOcclusionEnabled.sink{ [weak self] isEnabled in
            self?.updateObjectOcclusion(isEnabled: isEnabled)
        }
        
        self.lidarDebugCancellable = sessionSettings.$isLidarDebugEnabled.sink{ [weak self] isEnabled in
            self?.updateLidarDebug(isEnabled: isEnabled)
        }
        
        self.multiuserCancellable = sessionSettings.$isMultiUserEnabled.sink{ [weak self] isEnabled in
            self?.updateMultiuser(isEnabled: isEnabled)
        }
    }
    private func updatePeopleOcclusion(isEnabled: Bool){
        print("\(#file): isPeopleOcclusionEnabled is now \(isEnabled)")

        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            return
        }
        
        guard let configuration = self.session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        
        if configuration.frameSemantics.contains(.personSegmentationWithDepth) {
            configuration.frameSemantics.remove(.personSegmentationWithDepth)
        }
        else{
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        self.session.run(configuration)
        
    }
    
    private func initializeSettings(){
        self.updatePeopleOcclusion(isEnabled: sessionSettings.isPeopleOcclusionEnabled)
        self.updateObjectOcclusion(isEnabled: sessionSettings.isObjectOcclusionEnabled)
        self.updateLidarDebug(isEnabled: sessionSettings.isLidarDebugEnabled)
        self.updateMultiuser(isEnabled: sessionSettings.isMultiUserEnabled)
    }
    
    private func updateObjectOcclusion(isEnabled: Bool){
        print("\(#file): isObjectOcclusionEnabled is now \(isEnabled)")
        
        if self.environment.sceneUnderstanding.options.contains(.occlusion) {
            self.environment.sceneUnderstanding.options.remove(.occlusion)
        }
        else{
            self.environment.sceneUnderstanding.options.insert(.occlusion)
        }
    }
    
    private func updateLidarDebug(isEnabled: Bool){
        print("\(#file): isLidearDebugEnabled is now \(isEnabled)")
        
        if self.debugOptions.contains(.showSceneUnderstanding) {
            self.debugOptions.remove(.showSceneUnderstanding)
        }
        else {
            self.debugOptions.insert(.showSceneUnderstanding)
        }
    }
    
    private func updateMultiuser(isEnabled: Bool){
        print("\(#file): isMultiUserEnabled is now \(isEnabled)")
    }
}

//MARK: - object Deletion methods

extension CustomARView {
    func enableObjectDeletion() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        self.addGestureRecognizer(longPressGesture)
        
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        if let entity = self.entity(at: location) as? ModelEntity{
            modelDeletionManager?.entitySelectedForDeletion = entity
        }
    }
}
