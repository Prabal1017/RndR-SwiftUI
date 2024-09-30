import SwiftUI
import RealityKit
import ARKit

struct RoomModelView: View {
    var usdzURL: URL

    var body: some View {
        RoomModelViewContainer(usdzURL: usdzURL)
            .edgesIgnoringSafeArea(.all) // To use the full screen
    }
}

struct RoomModelViewContainer: UIViewRepresentable {
    var usdzURL: URL

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Load the USDZ model into the ARView
        do {
            let modelEntity = try Entity.load(contentsOf: usdzURL)
            let anchorEntity = AnchorEntity(world: [0, 0, 0])
            anchorEntity.addChild(modelEntity)
            arView.scene.addAnchor(anchorEntity)
        } catch {
            print("Failed to load model: \(error.localizedDescription)")
        }
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
