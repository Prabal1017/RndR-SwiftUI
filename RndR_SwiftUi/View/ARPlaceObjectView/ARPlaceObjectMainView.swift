////
////  ContentView.swift
////  ArView
////
////  Created by Prabal Kumar on 08/10/24.
////
//
//import SwiftUI
//import RealityKit
//import ARKit
//
//struct ARPlaceObjectMainView: View {
//    @EnvironmentObject var placementSettings: PlacementSettings
//    @EnvironmentObject var sessionSettings: SessionSettings
//    
//    @State private var isControlsVisible: Bool = true
//    @State private var showBrowse: Bool = false
//    @State private var showSettings: Bool = false
//    
//    @State private var arView: CustomARView?
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            if let arView = arView {
//                ARPlaceObjectViewContainer(arView: $arView, sessionSettings: sessionSettings)
//            } else {
//                ProgressView("Loading AR...")
//                    .onAppear {
//                        // Initialize the ARView
//                        arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
//                        arView?.startSession() // Start the session after initialization
//                        print("AR session started in onAppear")
//                    }
//            }
//
//            if self.placementSettings.selectedModel == nil {
//                ControlView(
//                    isControlsVisible: $isControlsVisible,
//                    showBrowse: $showBrowse,
//                    showSettings: $showSettings
//                )
//            } else {
//                PlacementView()
//            }
//        }
//        .onAppear {
//            // Ensure the AR session is running when this view appears
//            arView?.startSession()
//        }
//        .onDisappear {
//            // Stop the session when the view disappears
//            arView?.stopSession()
//            // Optionally clear the arView to free up resources
//            arView = nil
//        }
//    }
//}
//
//struct ARPlaceObjectViewContainer: UIViewRepresentable {
//    @Binding var arView: CustomARView?
//    var sessionSettings: SessionSettings
//
//    func makeUIView(context: Context) -> CustomARView {
//        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
//        print("ARView initialized in makeUIView")
//        arView.startSession() // Start the session here
//        return arView
//    }
//
//    func updateUIView(_ uiView: CustomARView, context: Context) {
//        // Ensure the view updates as expected
//        print("updateUIView called")
//        uiView.frame = UIScreen.main.bounds // Ensure it takes up the entire screen
//    }
//
//    func dismantleUIView(_ uiView: CustomARView, coordinator: ()) {
//        print("Dismantling ARPlaceObjectViewContainer, stopping session")
//        uiView.stopSession() // Stop the session if needed
//    }
//}
//
//
/////oldest code
////struct ARPlaceObjectViewContainer: UIViewRepresentable {
////    @EnvironmentObject var placementSettings: PlacementSettings
////    @EnvironmentObject var sessionSettings: SessionSettings
////
////    func makeUIView(context: Context) -> CustomARView {
////        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
////
////        // Start the AR session when the view is created
////        arView.startSession()
////        print("AR session started in makeUIView")
////
////        // Add subscriber
////        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { event in
////            self.updateScene(for: arView)
////        }
////
////        return arView
////    }
////
////    func updateUIView(_ uiView: CustomARView, context: Context) {
////        print("updateUIView called")
////    }
////
////    func dismantleUIView(_ uiView: CustomARView, coordinator: ()) {
////        print("Dismantling ARPlaceObjectViewContainer, stopping session")
////        uiView.stopSession()
////    }
////
////    private func updateScene(for arView: CustomARView) {
////        // Display focus entity logic
////        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
////
////        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
////            self.place(modelEntity, in: arView)
////            self.placementSettings.confirmedModel = nil
////        }
////    }
////
////    private func place(_ modelEntity: ModelEntity, in arView: ARView) {
////        // Clone model entity
////        let clonedEntity = modelEntity.clone(recursive: true)
////
////        // Enable translation and rotation gestures
////        clonedEntity.generateCollisionShapes(recursive: true)
////        arView.installGestures([.translation, .rotation], for: clonedEntity)
////
////        // Create an anchor Entity and add clonedEntity to it
////        let anchorEntity = AnchorEntity(plane: .any)
////        anchorEntity.addChild(clonedEntity)
////
////        // Add the anchor Entity to the arView.scene
////        arView.scene.addAnchor(anchorEntity)
////
////        print("Added Entity model to scene")
////    }
////}
//
//
//#Preview {
//    ARPlaceObjectMainView()
//        .environmentObject(PlacementSettings())
//        .environmentObject(SessionSettings())
//}
//
//










import SwiftUI

struct ARPlaceObjectMainView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var modelsViewModel: ModelViewModel
    
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    
    @State var selectedControlMode: Int = 0
    @State var isControlsVisible:Bool = true
    @State var showBrowse:Bool = false
    @State var showSettings:Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom){
            
            ARViewContainerdemo()
                .environmentObject(modelsViewModel)
                .edgesIgnoringSafeArea(.all)
            
            if self.placementSettings.selectedModel != nil{
                PlacementView()
            }else if self.modelDeletionManager.entitySelectedForDeletion != nil {
                DeletionView()
            }else {
                ControlView(selectedControlMode: $selectedControlMode, isControlsVisible: $isControlsVisible, showBrowse: $showBrowse, showSettings: $showSettings)
            }
        }
        .onAppear(){
            self.modelsViewModel.fetchData()
        }
//        .ignoresSafeArea(.all)
    }
}

#Preview {
    ARPlaceObjectMainView()
        .environmentObject(PlacementSettings())
        .environmentObject(SessionSettings())
        .environmentObject(SceneManager())
        .environmentObject(ModelViewModel())
        .environmentObject(ModelDeletionManager())
}
