//import SwiftUI
//import SceneKit
//
//struct Model3DView: View {
//    var modelUrl: URL
//    
//    var body: some View {
//        SceneView(
//            scene: load3DModel(from: modelUrl),
//            options: [.allowsCameraControl, .autoenablesDefaultLighting]
//        )
//        .edgesIgnoringSafeArea(.all)
//        .background(Color.red) // Background color for visibility
//    }
//    
//    func load3DModel(from url: URL) -> SCNScene? {
//        let scene = SCNScene()
//        scene.background.contents = UIColor.gray // Set the scene background color to red
//        
//        // Download the model data
//        downloadModel(from: url) { localURL, error in
//            guard let localURL = localURL, error == nil else {
//                print("Error downloading model: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            do {
//                let modelScene = try SCNScene(url: localURL, options: nil)
//                let node = modelScene.rootNode.clone()
//                
//                printNodeHierarchy(node: node) // Print node hierarchy
//                
//                if node.childNodes.isEmpty {
//                    print("Loaded node has no geometry")
//                } else {
//                    // Scale the node down significantly
//                    node.scale = SCNVector3(0.2, 0.2, 0.2)
//                    
//                    let (min, max) = node.boundingBox
//                    print("Model bounding box min: \(min), max: \(max)")
//                    
//                    node.position = SCNVector3(0, 0, 0) // Center it
//                    scene.rootNode.addChildNode(node)
//                    
//                    // Add a camera to the scene
//                    let cameraNode = SCNNode()
//                    cameraNode.camera = SCNCamera()
//                    cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
//                    cameraNode.look(at: node.position)
//                    scene.rootNode.addChildNode(cameraNode)
//                }
//            } catch {
//                print("Error loading 3D model from local URL: \(localURL) - \(error.localizedDescription)")
//            }
//        }
//        
//        return scene
//    }
//    
//    // Function to download the model
//    func downloadModel(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
//        let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//            
//            guard let tempLocalUrl = tempLocalUrl else {
//                completion(nil, nil)
//                return
//            }
//            
//            // Define the permanent location for the downloaded file
//            let fileManager = FileManager.default
//            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let permanentURL = documentsDirectory.appendingPathComponent("downloadedModel.usdz")
//            
//            do {
//                // Check if a file already exists at the destination
//                if fileManager.fileExists(atPath: permanentURL.path) {
//                    // Remove the existing file
//                    try fileManager.removeItem(at: permanentURL)
//                }
//                
//                // Move the downloaded file to the permanent location
//                try fileManager.moveItem(at: tempLocalUrl, to: permanentURL)
//                completion(permanentURL, nil)
//            } catch {
//                completion(nil, error)
//            }
//        }
//        task.resume()
//    }
//
//
//    // Function to print the node hierarchy
//    func printNodeHierarchy(node: SCNNode, indent: String = "") {
//        print("\(indent)\(node.name ?? "Unnamed Node")")
//        for child in node.childNodes {
//            printNodeHierarchy(node: child, indent: indent + "  ")
//            if let geometry = child.geometry {
//                print("  Geometry found in child node: \(child.name ?? "Unnamed Child")")
//            } else {
//                print("  No geometry in child node: \(child.name ?? "Unnamed Child")")
//            }
//        }
//    }
//}




import SwiftUI
import ARKit
import SceneKit

struct Model3DView: View {
    var modelUrl: URL
    @State private var selectedNode: SCNNode?
    @State private var isDragging: Bool = false
    @State private var initialPosition: SCNVector3 = SCNVector3(0, 0, 0)
    @State private var showModal: Bool = false
    @State private var selectedColor: Color = .red // Track selected color globally

    var body: some View {
        ZStack {
            // Keep the SCNView visible in the background
            ARSceneViewContainer(modelUrl: modelUrl, selectedNode: $selectedNode, isDragging: $isDragging, initialPosition: $initialPosition, selectedColor: $selectedColor)
                .edgesIgnoringSafeArea(.all)

            // Floating button to show the modal on top of the 3D view
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showModal = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding()
                }
            }

            // Use an overlay to show the modal
            if showModal {
                Color.black.opacity(0.3) // A semi-transparent background
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showModal = false // Close the modal when tapping outside
                    }

                AddModelModalView(selectedNode: $selectedNode, selectedColor: $selectedColor)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .frame(height: 300)
                    .transition(.move(edge: .bottom)) // Smooth transition from bottom
                    .onAppear {
                        // Ensures AR view does not get dismissed or disrupted
                    }
            }
        }
        .animation(.easeInOut, value: showModal) // Smooth transition
    }
}




struct AddModelModalView: View {
    @State private var selectedCategory: String = "Colours"
    @Binding var selectedNode: SCNNode?
    @Binding var selectedColor: Color // Pass the selected color to the parent view
    let categories = ["Colours", "Furniture", "Lighting"]

    var body: some View {
        VStack {
            Text("Add 3D Model")
                .font(.headline)
                .padding()

            Picker("Select a Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedCategory == "Colours" {
                WallColorPickerView(selectedColor: $selectedColor)
                    .padding()
            }

            Button("Close") {
                // Dismiss the modal without closing the SCNView
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .padding()
        }
    }
}

struct WallColorPickerView: View {
    @Binding var selectedColor: Color

    let wallColors: [Color] = [.white, .red, .blue, .green, .yellow]
    let grayShades: [Color] = [.black, .gray, .init(white: 0.75), .init(white: 0.9)] // Different gray shades

    var body: some View {
        VStack {
            Text("Select Wall Color")
                .font(.headline)

            HStack {
                ForEach(wallColors, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                    }) {
                        Circle()
                            .fill(color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: selectedColor == color ? 2 : 0)
                            )
                    }
                }
            }
            .padding(.bottom)

            HStack {
                ForEach(grayShades, id: \.self) { gray in
                    Button(action: {
                        selectedColor = gray
                    }) {
                        Circle()
                            .fill(gray)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: selectedColor == gray ? 2 : 0)
                            )
                    }
                }
            }
        }
    }
}

struct ARSceneViewContainer: UIViewRepresentable {
    var modelUrl: URL
    @Binding var selectedNode: SCNNode?
    @Binding var isDragging: Bool
    @Binding var initialPosition: SCNVector3
    @Binding var selectedColor: Color

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true

        let scene = load3DModel(from: modelUrl)
        sceneView.scene = scene

        // Long press to select and manipulate the component
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        sceneView.addGestureRecognizer(longPressGesture)

        // Pan gesture for moving the selected component
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)

        // Pinch gesture for scaling the selected component
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)

        // Rotation gesture for rotating the selected component
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleRotation(_:)))
        sceneView.addGestureRecognizer(rotationGesture)

        // Double tap gesture for changing the color of the component
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGesture)

        // Single tap gesture for selecting the whole model
        let singleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleSingleTap(_:)))
        singleTapGesture.require(toFail: doubleTapGesture) // Ensure single tap doesn't conflict with double tap
        sceneView.addGestureRecognizer(singleTapGesture)

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
        var initialRotation: SCNVector4 = SCNVector4Zero
        var initialScale: SCNVector3 = SCNVector3(1, 1, 1)
        var initialPosition: SCNVector3 = SCNVector3Zero

        init(_ parent: ARSceneViewContainer) {
            self.parent = parent
        }

        // Long press to select and enable manipulation of a node
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView else { return }

            if gesture.state == .began {
                let location = gesture.location(in: sceneView)
                let hitResults = sceneView.hitTest(location, options: [:])

                if let hitNode = hitResults.first?.node {
                    // Select the component
                    parent.selectedNode = hitNode
                    initialRotation = hitNode.rotation
                    initialScale = hitNode.scale
                    initialPosition = hitNode.position
                    print("DEBUG: Long press selected node: \(hitNode.name ?? "Unnamed Node")")
                }
            }
        }

        // Single tap gesture for selecting the whole model
        @objc func handleSingleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView else { return }

            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])

            if let hitNode = hitResults.first?.node {
                // Traverse up the hierarchy to find the root node of the entire model
                var currentNode = hitNode
                while let parent = currentNode.parent, parent.name != nil {
                    currentNode = parent
                }

                // Optional: Check for a specific node name if your root node has a unique name
                if currentNode.name == "RoomModel" {
                    // Select the entire model
                    parent.selectedNode = currentNode
                    print("DEBUG: Single tap selected entire model node: \(currentNode.name ?? "Unnamed Root Node")")
                } else {
                    // If not using specific names, just select the topmost node
                    parent.selectedNode = currentNode
                    print("DEBUG: Single tap selected topmost node: \(currentNode.name ?? "Unnamed Topmost Node")")
                }
            }
        }


        // Pan gesture for moving the selected component
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView, let node = parent.selectedNode else { return }

            let translation = gesture.translation(in: sceneView)
            let newPosition = SCNVector3(
                initialPosition.x + Float(translation.x) * 0.01,
                initialPosition.y - Float(translation.y) * 0.01,
                initialPosition.z
            )

            if gesture.state == .changed {
                print("DEBUG: Moving node to position: \(newPosition)")
                node.position = newPosition
            }

            if gesture.state == .ended {
                print("DEBUG: Finished moving node")
            }
        }

        // Pinch gesture for scaling the selected component
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let node = parent.selectedNode else { return }

            let newScale = SCNVector3(
                initialScale.x * Float(gesture.scale),
                initialScale.y * Float(gesture.scale),
                initialScale.z * Float(gesture.scale)
            )

            if gesture.state == .changed {
                print("DEBUG: Scaling node to scale: \(newScale)")
                node.scale = newScale
            }

            if gesture.state == .ended {
                print("DEBUG: Finished scaling node")
            }
        }

        // Rotation gesture for rotating the selected component
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let node = parent.selectedNode else { return }

            let rotation = Float(gesture.rotation)

            if gesture.state == .changed {
                let newRotation = SCNVector4(0, 1, 0, initialRotation.w + rotation)
                print("DEBUG: Rotating node to: \(newRotation)")
                node.rotation = newRotation
            }

            if gesture.state == .ended {
                print("DEBUG: Finished rotating node")
            }
        }

        // Double tap to change color of the selected node
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView else { return }

            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])

            if let hitNode = hitResults.first?.node {
                // Change color of the selected node
                applyColorToNode(hitNode)
                print("DEBUG: Double-tap changed color of node: \(hitNode.name ?? "Unnamed Node")")
            }
        }

        func applyColorToNode(_ node: SCNNode) {
            let material = node.geometry?.firstMaterial
            let color = UIColor(parent.selectedColor)
            material?.diffuse.contents = color
        }
    }
}
