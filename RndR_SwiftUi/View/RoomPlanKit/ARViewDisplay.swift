////import SwiftUI
////import RealityKit
////import ARKit
////
////struct ARViewDisplay: UIViewRepresentable {
////    var modelUrl: String
////    
////    func makeUIView(context: Context) -> ARView {
////        let arView = ARView(frame: .zero)
////        
////        // Load the model into the ARView
////        loadModel(from: modelUrl, on: arView)
////        
////        return arView
////    }
////    
////    func updateUIView(_ uiView: ARView, context: Context) {}
////    
////    private func loadModel(from urlString: String, on arView: ARView) {
////        guard let url = URL(string: urlString) else {
////            print("Invalid URL string: \(urlString)")
////            return
////        }
////        
////        print("Loading model from URL: \(url)")
////        
////        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempModel.usdz")
////        
////        // Delete any existing file with the same name
////        if FileManager.default.fileExists(atPath: tempURL.path) {
////            do {
////                try FileManager.default.removeItem(at: tempURL)
////            } catch {
////                print("Failed to remove existing file: \(error.localizedDescription)")
////                return
////            }
////        }
////        
////        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
////            if let error = error {
////                print("Error downloading model: \(error.localizedDescription)")
////                return
////            }
////            
////            guard let location = location else {
////                print("Download location is nil")
////                return
////            }
////            
////            do {
////                try FileManager.default.moveItem(at: location, to: tempURL)
////                DispatchQueue.main.async {
////                    loadModelFromTempURL(tempURL, on: arView)
////                }
////            } catch {
////                print("Failed to move downloaded model file: \(error.localizedDescription)")
////            }
////        }
////        task.resume()
////    }
////
////    
////    private func loadModelFromTempURL(_ url: URL, on arView: ARView) {
////        print("Loading model from local file: \(url)")
////        
////        let entity: Entity
////        do {
////            let loadedEntity = try Entity.load(contentsOf: url)
////            if let modelEntity = loadedEntity as? ModelEntity {
////                entity = modelEntity
////            } else {
////                print("Loaded entity is not a ModelEntity. Adding as a generic Entity.")
////                entity = loadedEntity
////            }
////            print("Successfully loaded entity.")
////        } catch {
////            print("Failed to load entity: \(error.localizedDescription)")
////            return
////        }
////        
////        // Create an anchor and add the entity to the ARView
////        let anchor = AnchorEntity(world: .zero)
////        anchor.addChild(entity)
////        
////        arView.scene.addAnchor(anchor)
////        arView.scene.anchors.append(anchor)
////        
////        print("Entity successfully added to ARView.")
////    }
////}
////
////
////
////
//////import SwiftUI
//////import RealityKit
//////import ARKit
//////
//////struct ARViewDisplay: UIViewRepresentable {
//////    var modelUrl: String
//////    
//////    func makeUIView(context: Context) -> ARView {
//////        let arView = ARView(frame: .zero)
//////        
//////        // Load the model and place it in front of the camera
//////        loadModel(from: modelUrl, on: arView)
//////        
//////        return arView
//////    }
//////    
//////    func updateUIView(_ uiView: ARView, context: Context) {}
//////    
//////    private func loadModel(from urlString: String, on arView: ARView) {
//////        guard let url = URL(string: urlString) else {
//////            print("Invalid URL string: \(urlString)")
//////            return
//////        }
//////        
//////        print("Loading model from URL: \(url)")
//////        
//////        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempModel.usdz")
//////        
//////        // Remove any existing file with the same name
//////        if FileManager.default.fileExists(atPath: tempURL.path) {
//////            do {
//////                try FileManager.default.removeItem(at: tempURL)
//////            } catch {
//////                print("Failed to remove existing file: \(error.localizedDescription)")
//////                return
//////            }
//////        }
//////        
//////        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
//////            if let error = error {
//////                print("Error downloading model: \(error.localizedDescription)")
//////                return
//////            }
//////            
//////            guard let location = location else {
//////                print("Download location is nil")
//////                return
//////            }
//////            
//////            do {
//////                try FileManager.default.moveItem(at: location, to: tempURL)
//////                DispatchQueue.main.async {
//////                    loadModelFromTempURL(tempURL, on: arView)
//////                }
//////            } catch {
//////                print("Failed to move downloaded model file: \(error.localizedDescription)")
//////            }
//////        }
//////        task.resume()
//////    }
//////    
//////    private func loadModelFromTempURL(_ url: URL, on arView: ARView) {
//////        print("Loading model from local file: \(url)")
//////        
//////        let entity: Entity
//////        do {
//////            let loadedEntity = try Entity.load(contentsOf: url)
//////            if let modelEntity = loadedEntity as? ModelEntity {
//////                // Set scale for better visibility
//////                modelEntity.scale = [0.5, 0.5, 0.5] // Adjust scale as needed
//////                entity = modelEntity
//////            } else {
//////                print("Loaded entity is not a ModelEntity. Adding as a generic Entity.")
//////                entity = loadedEntity
//////            }
//////            print("Successfully loaded entity.")
//////        } catch {
//////            print("Failed to load entity: \(error.localizedDescription)")
//////            return
//////        }
//////        
//////        // Create an anchor in front of the camera
//////        let cameraAnchor = AnchorEntity(.camera)
//////        
//////        // Position the entity in front of the camera (adjust z-axis for distance)
//////        entity.position = [0, 0, -0.5] // 0.5 meters in front of the camera
//////        
//////        cameraAnchor.addChild(entity)
//////        
//////        // Add the anchor to the ARView
//////        arView.scene.addAnchor(cameraAnchor)
//////        
//////        print("Entity successfully added to ARView in front of the camera.")
//////    }
//////}
//
//
//
//
//
//
//
//import SwiftUI
//import RealityKit
//import ARKit
//
//struct ARViewDisplay: UIViewRepresentable {
//    var modelUrl: String
//    
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//        
//        // Configure AR session
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal, .vertical]
//        arView.session.run(config)
//        
//        // Add directional light for the scene
//        addLighting(to: arView)
//        
//        // Load the model into the ARView
//        loadModel(from: modelUrl, on: arView)
//        
//        // Add gesture recognizers to ARView
//        addGestures(to: arView, context: context)
//        
//        return arView
//    }
//    
//    func updateUIView(_ uiView: ARView, context: Context) {}
//    
//    // Add lighting to the AR scene
//    private func addLighting(to arView: ARView) {
//        let light = DirectionalLight()
//        light.light.intensity = 1000 // Adjust intensity if needed
//        light.position = [0, 10, 0] // Place the light above the scene
//        
//        let lightAnchor = AnchorEntity(world: .zero)
//        lightAnchor.addChild(light)
//        
//        arView.scene.addAnchor(lightAnchor)
//    }
//    
//    // Load model from URL
//    private func loadModel(from urlString: String, on arView: ARView) {
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL string: \(urlString)")
//            return
//        }
//        
//        print("Loading model from URL: \(url)")
//        
//        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempModel.usdz")
//        
//        if FileManager.default.fileExists(atPath: tempURL.path) {
//            do {
//                try FileManager.default.removeItem(at: tempURL)
//            } catch {
//                print("Failed to remove existing file: \(error.localizedDescription)")
//                return
//            }
//        }
//        
//        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
//            if let error = error {
//                print("Error downloading model: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let location = location else {
//                print("Download location is nil")
//                return
//            }
//            
//            do {
//                try FileManager.default.moveItem(at: location, to: tempURL)
//                DispatchQueue.main.async {
//                    self.loadModelFromTempURL(tempURL, on: arView)
//                }
//            } catch {
//                print("Failed to move downloaded model file: \(error.localizedDescription)")
//            }
//        }
//        task.resume()
//    }
//    
//    // Load model from the downloaded temp file
//    private func loadModelFromTempURL(_ url: URL, on arView: ARView) {
//        print("Loading model from local file: \(url)")
//        
//        do {
//            let entity = try Entity.load(contentsOf: url)
//            
//            if let modelEntity = entity as? ModelEntity {
//                print("Successfully loaded ModelEntity.")
//                
//                // Scale and position adjustments
//                modelEntity.scale = SIMD3(repeating: 0.1)
//                modelEntity.position = [0, 0, 0]
//                
//                let anchor = AnchorEntity(world: .zero)
//                anchor.addChild(modelEntity)
//                arView.scene.addAnchor(anchor)
//                print("ModelEntity successfully added to ARView.")
//            } else {
//                print("The loaded entity is not a ModelEntity. It is of type: \(type(of: entity))")
//                
//                // Try adding the generic entity to the ARView scene
//                let anchor = AnchorEntity(world: .zero)
//                anchor.addChild(entity)
//                arView.scene.addAnchor(anchor)
//                
//                print("Generic Entity successfully added to ARView.")
//            }
//        } catch {
//            print("Failed to load entity: \(error.localizedDescription)")
//        }
//    }
//
//
//
//    
//    // Coordinator to handle gestures
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    private func addGestures(to arView: ARView, context: Context) {
//        let coordinator = context.coordinator
//        
//        // Tap gesture for selecting the model
//        let tapGesture = UITapGestureRecognizer(target: coordinator, action: #selector(coordinator.handleTap(_:)))
//        arView.addGestureRecognizer(tapGesture)
//        
//        // Pinch gesture for scaling the model
//        let pinchGesture = UIPinchGestureRecognizer(target: coordinator, action: #selector(coordinator.handlePinch(_:)))
//        arView.addGestureRecognizer(pinchGesture)
//        
//        // Pan gesture for moving the model around
//        let panGesture = UIPanGestureRecognizer(target: coordinator, action: #selector(coordinator.handlePan(_:)))
//        arView.addGestureRecognizer(panGesture)
//        
//        // Rotation gesture for rotating the model
//        let rotationGesture = UIRotationGestureRecognizer(target: coordinator, action: #selector(coordinator.handleRotation(_:)))
//        arView.addGestureRecognizer(rotationGesture)
//        
//        // Long press gesture for coloring the model
//        let longPressGesture = UILongPressGestureRecognizer(target: coordinator, action: #selector(coordinator.handleLongPress(_:)))
//        arView.addGestureRecognizer(longPressGesture)
//    }
//    
//    // Coordinator class to handle gesture recognizers
//    class Coordinator: NSObject {
//        var parent: ARViewDisplay
//        var selectedEntity: ModelEntity?
//        
//        init(_ parent: ARViewDisplay) {
//            self.parent = parent
//        }
//        
//        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//            let arView = gesture.view as! ARView
//            let location = gesture.location(in: arView)
//            if let entity = arView.entity(at: location) as? ModelEntity {
//                print("Tap detected on model.")
//                selectedEntity = entity // Allow selecting the model
//            }
//        }
//        
//        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
//            guard let entity = selectedEntity else { return }
//            if gesture.state == .changed {
//                let scale = gesture.scale
//                entity.scale = SIMD3(repeating: Float(scale))
//            }
//        }
//        
//        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//            guard let entity = selectedEntity else { return }
//            let arView = gesture.view as! ARView
//            let translation = gesture.translation(in: arView)
//            entity.position.x += Float(translation.x / 1000)
//            entity.position.z += Float(translation.y / 1000)
//            gesture.setTranslation(.zero, in: arView)
//        }
//        
//        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
//            guard let entity = selectedEntity else { return }
//            if gesture.state == .changed {
//                entity.transform.rotation = simd_quatf(angle: Float(gesture.rotation), axis: [0, 1, 0])
//            }
//        }
//        
//        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//            let arView = gesture.view as! ARView
//            let location = gesture.location(in: arView)
//            if let entity = arView.entity(at: location) as? ModelEntity, gesture.state == .began {
//                print("Long press detected.")
//                entity.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)] // Example color change
//            }
//        }
//    }
//}
