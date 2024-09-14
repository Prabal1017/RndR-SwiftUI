import SceneKit
import ARKit

extension Coordinator {
    // Convert ARMeshAnchor to SceneKit geometry
    func createGeometry(from meshAnchor: ARMeshAnchor) -> SCNGeometry {
        let geometrySource = ARGeometrySource(meshAnchor: meshAnchor)
        let geometryElement = ARGeometryElement(meshAnchor: meshAnchor)
        
        let geometry = SCNGeometry(sources: [geometrySource], elements: [geometryElement])
        geometry.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
        
        return geometry
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let meshAnchor = anchor as? ARMeshAnchor {
            let meshGeometry = createGeometry(from: meshAnchor)
            node.geometry = meshGeometry
        }
    }
}
