//import SwiftUI
//import RealityKit
//
//struct ARViewContainer: UIViewRepresentable {
//    var usdzURL: URL
//    
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//        loadModel(on: arView)
//        return arView
//    }
//    
//    func updateUIView(_ uiView: ARView, context: Context) {}
//    
//    private func loadModel(on arView: ARView) {
//        let modelEntity = try? Entity.loadModel(contentsOf: usdzURL)
//        let anchor = AnchorEntity()
//        anchor.addChild(modelEntity!)
//        arView.scene.anchors.append(anchor)
//    }
//}
