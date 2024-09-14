import SwiftUI
import ARKit
import RealityKit

import ModelIO
import SceneKit.ModelIO

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.autoenablesDefaultLighting = true
        arView.scene = SCNScene()
        
        // Setup AR Session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]  // Detect horizontal and vertical planes
        configuration.environmentTexturing = .automatic         // Automatic environment mapping
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .meshWithClassification
        }
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, ARSCNViewDelegate {
    var parent: ARViewContainer

    init(_ parent: ARViewContainer) {
        self.parent = parent
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let meshAnchor = anchor as? ARMeshAnchor {
            let meshGeometry = createGeometry(from: meshAnchor)
            node.geometry = meshGeometry
            sceneView?.scene.rootNode.addChildNode(node)
        }
    }
}

func exportMesh(node: SCNNode, to url: URL) {
    let asset = MDLAsset()
    
    if let mesh = node.geometry {
        let mdlMesh = MDLMesh(scnGeometry: mesh)
        asset.add(mdlMesh)
    }
    
    do {
        try asset.export(to: url)
        print("Model exported successfully to \(url)")
    } catch {
        print("Failed to export model: \(error)")
    }
}
