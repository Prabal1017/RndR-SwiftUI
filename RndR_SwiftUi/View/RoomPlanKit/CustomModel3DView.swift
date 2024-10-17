import SwiftUI
import SDWebImageSwiftUI
import ARKit
import SceneKit

import FirebaseStorage
import RealityKit

struct Model3DView: View {
    var modelUrl: URL
    @State private var selectedNode: SCNNode?
    @State private var isDragging: Bool = false
    @State private var initialPosition: SCNVector3 = SCNVector3(0, 0, 0)
    @State private var showModal: Bool = false
    @State private var selectedColor: Color = .red
    @State private var showSavedMessage = false
    @State private var uploadProgress: Double = 0.0
    @StateObject var viewModel: CustomModel3DViewModel
    
    @State private var selectedTexture: String?
    @State private var selectedFurniture: FurnitureModel?
    @State private var hasMadeChanges: Bool = false
    
    var body: some View {
        ZStack {
            ARSceneViewContainer(
                modelUrl: modelUrl,
                selectedNode: $selectedNode,
                isDragging: $isDragging,
                initialPosition: $initialPosition,
                selectedColor: $selectedColor,
                selectedTextureName: $selectedTexture
            )
            .edgesIgnoringSafeArea(.all)
            .onChange(of: selectedNode) { _ in
                hasMadeChanges = true
            }
            .onChange(of: selectedColor) { _ in
                hasMadeChanges = true
            }
            .onChange(of: selectedTexture) { _ in
                hasMadeChanges = true
            }
            .onChange(of: selectedFurniture) { newValue in
                if let furnitureModel = newValue {
                    loadSelectedFurnitureModel(furnitureModel: furnitureModel)
                }
            }
            
            // Success message when the model is saved
            if showSavedMessage {
                HStack {
                    Text("Model saved successfully!")
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .offset(y: 0)
                .frame(maxWidth: .infinity)
                .padding()
                .transition(.move(edge: .top))
                .zIndex(1)
            }
            
            // Progress view for upload
            if uploadProgress > 0.0 && uploadProgress < 1.0 {
                VStack {
                    Text("Uploading model...")
                        .foregroundColor(.white)
                        .padding()
                    
                    ProgressView(value: uploadProgress, total: 1.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(width: 60, height: 60)
                        .padding()
                }
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding()
                .zIndex(1)
            }
            
            // Buttons - save, add
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    // Save button
                    Button(action: {
                        // Logic to save the model
                        if let selectedNode = selectedNode {
                            // Traverse up to find the root node
                            var currentNode = selectedNode
                            while let parentNode = currentNode.parent, parentNode.name != nil {
                                currentNode = parentNode
                            }
                            
                            if currentNode.name == "RoomModel" {
                                self.selectedNode = currentNode
                                print("DEBUG: Automatically selected the entire model node: \(currentNode.name ?? "Unnamed Root Node")")
                            } else {
                                self.selectedNode = currentNode
                                print("DEBUG: Automatically selected the topmost node: \(currentNode.name ?? "Unnamed Topmost Node")")
                            }
                        }
                        
                        viewModel.saveEditedModel(selectedNode: selectedNode, progressHandler: { progress in
                            self.uploadProgress = progress
                        }) { success in
                            if success {
                                showSavedMessage = true
                                uploadProgress = 1.0
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showSavedMessage = false
                                    }
                                }
                                hasMadeChanges = false
                            }
                        }
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 24))
                            .offset( y: -2)
                            .foregroundColor(.white)
                            .padding()
                            .background(hasMadeChanges ? Color.green : Color.gray)                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.bottom)
                    .disabled(!hasMadeChanges)
                    
                    // Floating button to show the modal
                    Button(action: {
                        showModal = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
            }
            .padding()
            .padding(.bottom, 85)
        }
        .animation(.easeInOut, value: showSavedMessage)
        .sheet(isPresented: $showModal) {
            AddModelModalView(
                selectedNode: $selectedNode,
                selectedColor: $selectedColor,
                selectedTexture: $selectedTexture,
                selectedFurniture: $selectedFurniture,
                showModal: $showModal
            )
        }
    }
    
    private func loadSelectedFurnitureModel(furnitureModel: FurnitureModel) {
        // Create a Firebase Storage reference from the URL
        let storageRef = Storage.storage().reference(forURL: furnitureModel.furnitureUrl)
        
        // Download the .usdz model to a temporary location
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("\(furnitureModel.name).usdz")
        
        // Start the download
        storageRef.write(toFile: tempUrl) { url, error in
            if let error = error {
                print("Error downloading model from Firebase Storage: \(error)")
                return
            }
            
            guard let url = url else {
                print("Failed to get the downloaded model URL.")
                return
            }
            
            // Load the furniture scene from the downloaded .usdz file
            do {
                let scene = try SCNScene(url: url, options: nil)
                let furnitureNode = scene.rootNode
                
                // Calculate the bounding box of the furniture model
                let (minVec, maxVec) = furnitureNode.boundingBox
                let modelSize = SCNVector3(
                    maxVec.x - minVec.x,
                    maxVec.y - minVec.y,
                    maxVec.z - minVec.z
                )
                
                // Determine an appropriate scale based on the model size
                let maxDimension = max(modelSize.x, modelSize.y, modelSize.z)
                let desiredSize: Float = 0.5  // Adjust this value to your desired furniture size in the scene
                let scaleFactor = desiredSize / maxDimension
                furnitureNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
                
                // Add the furniture model to the selected room model (selectedNode)
                guard let roomNode = selectedNode else {
                    print("Room model is not selected, cannot add furniture.")
                    return
                }
                roomNode.addChildNode(furnitureNode)
                
                print("Successfully added \(furnitureModel.name) to the room model with scaling factor: \(scaleFactor).")
            } catch {
                print("Error loading the downloaded model: \(error)")
            }
        }
    }

}


//MARK: - PopUp view for adding color, lighting, and furniture
struct AddModelModalView: View {
    @State private var selectedCategory: String = "Colours"
    @Binding var selectedNode: SCNNode?
    @Binding var selectedColor: Color
    @Binding var selectedTexture: String? // Bind the selected texture to the parent
    @Binding var selectedFurniture: FurnitureModel? // Bind the selected furniture to the parent
    @Binding var showModal: Bool
    
    @StateObject var furnitureModelsViewModel = FurnitureModelViewModel()
    
    let categories = ["Colours", "Wall textures", "Furniture"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
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
                } else if selectedCategory == "Wall textures" {
                    WallTexturePickerView(selectedTexture: $selectedTexture)
                        .padding()
                } else if selectedCategory == "Furniture" {
                    FurniturePickerView(viewModel: furnitureModelsViewModel, selectedFurniture: $selectedFurniture) // Add FurniturePickerView
                        .padding()
                }
                
                Spacer()
            }
            .onAppear(){
                self.furnitureModelsViewModel.fetchFurnitureModels()
            }
            .navigationTitle("Customize 3D Model")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                showModal = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
        }
    }
}

//MARK: - Furniture picker view
struct FurniturePickerView: View {
    @StateObject var viewModel: FurnitureModelViewModel // ViewModel for furniture models
    @Binding var selectedFurniture: FurnitureModel? // Bind the selected furniture to the parent
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Select Furniture")
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.furnitureModels) { furniture in
                        Button(action: {
                            selectedFurniture = furniture // Set selected furniture
                        }) {
                            if let displayImage = furniture.displayImage {
                                WebImage(url: displayImage) // Use WebImage for loading
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedFurniture == furniture ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .background(.thickMaterial)
                                    .cornerRadius(10)
//                                    .indicator(.activity)
                            } else {
                                // Fallback image in case displayImage is nil
                                Color.gray
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchFurnitureModels() // Fetch furniture models when the view appears
        }
    }
}


//MARK: - Wall textures picker view

struct WallTexturePickerView: View {
    @Binding var selectedTexture: String? // Bind the selected texture to the parent
    
    let textures = (1...17).map { "Wall_textures/\($0)" } // Array of texture names in the asset catalog
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Select Wall Texture")
                .font(.headline)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(textures, id: \.self) { texture in
                        Button(action: {
                            selectedTexture = texture // Set selected texture
                        }) {
                            Image(texture)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedTexture == texture ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
            }
        }
    }
}


import SwiftUI

import SwiftUI

// MARK: - Wall Color Picker View
struct WallColorPickerView: View {
    @Binding var selectedColor: Color
    
    let wallColors: [Color] = [.red, .blue, .green, .yellow, .brown, .purple]
    let grayShades: [Color] = [.black, .gray, .init(white: 0.75), .init(white: 0.9), .white] // Different gray shades
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Select Wall Color")
                .font(.headline)
                .padding(.bottom)
            
            // Using LazyVGrid for wall colors
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(wallColors, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                    }) {
                        // Change shape based on selection
                        if selectedColor == color {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(color)
                                .frame(width: 100, height: 100)
                        } else {
                            Circle()
                                .fill(color)
                                .frame(width: 100, height: 100)
                        }
                    }
                    .padding()
                    .shadow(radius: 5)
                }
            }
            
            // Using LazyVGrid for wall colors
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(grayShades, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                    }) {
                        // Change shape based on selection
                        if selectedColor == color {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(color)
                                .frame(width: 100, height: 100)
                        } else {
                            Circle()
                                .fill(color)
                                .frame(width: 100, height: 100)
                        }
                    }
                    .padding()
                    .shadow(radius: 5)
                }
            }
        }
        .padding() // Add padding around the entire view
    }
}


//MARK: - gestures
struct ARSceneViewContainer: UIViewRepresentable {
    var modelUrl: URL
    @Binding var selectedNode: SCNNode?
    @Binding var isDragging: Bool
    @Binding var initialPosition: SCNVector3
    @Binding var selectedColor: Color
    @Binding var selectedTextureName: String?
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        
        let scene = load3DModel(from: modelUrl)
        sceneView.scene = scene
        
        // Create a directional light
        let light = SCNLight()
        light.type = .directional
        light.color = UIColor.white
        light.castsShadow = true // Optional: Enable shadows if desired
        
        // Create a light node and position it
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10) // Adjust position as needed
        lightNode.look(at: SCNVector3(0, 0, 0)) // Make sure the light points toward your walls
        
        // Add the light node to your scene
        scene?.rootNode.addChildNode(lightNode)
        
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
        
        // Triple tap gesture for applying the selected texture
        let tripleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTripleTap(_:)))
        tripleTapGesture.numberOfTapsRequired = 3
        sceneView.addGestureRecognizer(tripleTapGesture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func load3DModel(from url: URL) -> SCNScene? {
        let scene = SCNScene()
        
        // Create a gradient background
        scene.background.contents = createGradientImage()
        
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
    
    // Helper function to create gradient background
    func createGradientImage() -> UIImage? {
        let size = CGSize(width: 1, height: 500) // height can be adjusted for a smoother gradient
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let gradientImage = renderer.image { context in
            let colors = [UIColor.black.cgColor, UIColor.gray.cgColor, UIColor.black.cgColor]
            let locations: [CGFloat] = [0.0, 0.5, 1.0] // Transition points
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) {
                let startPoint = CGPoint(x: 0.5, y: 0.0)
                let endPoint = CGPoint(x: 0.5, y: size.height)
                context.cgContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
            }
        }
        
        return gradientImage
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
                node.position = newPosition
            }
            
            if gesture.state == .ended {
                // Update initial position to the current position for future gestures
                initialPosition = node.position
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
                node.scale = newScale
            }
            
            if gesture.state == .ended {
                // Update initial scale to the current scale for future gestures
                initialScale = node.scale
            }
        }

        // Rotation gesture for rotating the selected component
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let node = parent.selectedNode else { return }
            
            let rotation = Float(gesture.rotation)
            
            if gesture.state == .changed {
                let newRotation = SCNVector4(0, 1, 0, initialRotation.w + rotation)
                node.rotation = newRotation
            }
            
            if gesture.state == .ended {
                // Update initial rotation to the current rotation for future gestures
                initialRotation = node.rotation
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
        
        // Triple tap to apply texture to selected node
        @objc func handleTripleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView,
                  let selectedNode = parent.selectedNode,
                  let textureName = parent.selectedTextureName else { return } // Use parent to access selectedTextureName
            
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])
            
            if let hitNode = hitResults.first?.node {
                applyTextureToNode(to: hitNode, textureName: textureName) // Pass the selected texture name
                print("DEBUG: Triple-tap applied texture to node: \(hitNode.name ?? "Unnamed Node")")
            }
        }
        
        
        // Function to apply a texture to a wall
        func applyTextureToNode(to node: SCNNode, textureName: String) {
            let textureMaterial = SCNMaterial()
            
            // Use the texture name passed as a parameter
            textureMaterial.diffuse.contents = UIImage(named: textureName) // Use the provided texture name
            
            // Enable texture repeating
            textureMaterial.diffuse.wrapT = .repeat
            textureMaterial.diffuse.wrapS = .repeat
            
            // Set the repeat count (e.g., 2x2 repetitions)
            textureMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(2.0, 2.0, 1.0) // Adjust values for scaling
            textureMaterial.isDoubleSided = true // Ensure it is double-sided if needed
            textureMaterial.lightingModel = .phong // Set the lighting model
            textureMaterial.shininess = 0.5 // Adjust shininess (specular highlights)
            
            // Assign the material to the geometry
            if let geometry = node.geometry {
                geometry.materials = [textureMaterial]
            } else {
                print("Warning: Node does not have geometry.")
            }
        }
    }
}
