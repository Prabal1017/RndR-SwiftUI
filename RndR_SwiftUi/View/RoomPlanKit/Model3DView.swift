import SwiftUI
import ARKit
import SceneKit

struct Model3DView: View {
    var modelUrl: URL
    @State private var selectedNode: SCNNode?
    @State private var isDragging: Bool = false
    @State private var initialPosition: SCNVector3 = SCNVector3(0, 0, 0)

    var body: some View {
        ARSceneViewContainer(modelUrl: modelUrl, selectedNode: $selectedNode, isDragging: $isDragging, initialPosition: $initialPosition)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARSceneViewContainer: UIViewRepresentable {
    var modelUrl: URL
    @Binding var selectedNode: SCNNode?
    @Binding var isDragging: Bool
    @Binding var initialPosition: SCNVector3

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true

        let scene = load3DModel(from: modelUrl)
        sceneView.scene = scene

        // Adding gestures to the SCNView
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        sceneView.addGestureRecognizer(longPressGesture)

        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func load3DModel(from url: URL) -> SCNScene? {
        let scene = SCNScene()
        scene.background.contents = UIColor.gray

        downloadModel(from: url) { localURL, error in
            guard let localURL = localURL, error == nil else {
                print("DEBUG: Error downloading model: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let modelScene = try SCNScene(url: localURL, options: nil)
                let node = modelScene.rootNode.clone()

                if node.childNodes.isEmpty {
                    print("DEBUG: Loaded node has no geometry")
                } else {
                    node.scale = SCNVector3(0.2, 0.2, 0.2)
                    node.position = SCNVector3(0, 0, 0)
                    scene.rootNode.addChildNode(node)

                    let cameraNode = SCNNode()
                    cameraNode.camera = SCNCamera()
                    cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
                    cameraNode.look(at: node.position)
                    scene.rootNode.addChildNode(cameraNode)
                    
                    print("DEBUG: Successfully loaded 3D model with node \(node.name ?? "Unnamed Node")")
                }
            } catch {
                print("DEBUG: Error loading 3D model from local URL: \(localURL) - \(error.localizedDescription)")
            }
        }

        return scene
    }

    func downloadModel(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let tempLocalUrl = tempLocalUrl else {
                completion(nil, nil)
                return
            }

            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let permanentURL = documentsDirectory.appendingPathComponent("downloadedModel.usdz")

            do {
                if fileManager.fileExists(atPath: permanentURL.path) {
                    try fileManager.removeItem(at: permanentURL)
                }

                try fileManager.moveItem(at: tempLocalUrl, to: permanentURL)
                completion(permanentURL, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }

    class Coordinator: NSObject {
        var parent: ARSceneViewContainer

        init(_ parent: ARSceneViewContainer) {
            self.parent = parent
        }

        // Handle Long Press Gesture
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView else { return }

            if gesture.state == .began {
                let location = gesture.location(in: sceneView)
                let hitResults = sceneView.hitTest(location, options: [:])

                if let hitNode = hitResults.first?.node {
                    parent.selectedNode = hitNode
                    parent.isDragging = true
                    parent.initialPosition = hitNode.position
                    print("DEBUG: Long press selected node: \(hitNode.name ?? "Unnamed Node")")
                } else {
                    print("DEBUG: No node selected on long press")
                }
            }
        }

        // Handle Pan Gesture (Dragging)
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView, let node = parent.selectedNode else { return }

            let translation = gesture.translation(in: sceneView)
            let newPosition = SCNVector3(
                parent.initialPosition.x + Float(translation.x) * 0.01,
                parent.initialPosition.y - Float(translation.y) * 0.01,
                parent.initialPosition.z
            )

            if gesture.state == .changed {
                print("DEBUG: Dragging node to new position: \(newPosition)")
                node.position = newPosition
            }

            if gesture.state == .ended {
                parent.isDragging = false
                print("DEBUG: Dragging ended for node \(node.name ?? "Unnamed Node")")
            }
        }
    }
}
