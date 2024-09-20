import SwiftUI
import SceneKit

struct Model3DView: View {
    var modelUrl: URL
    
    var body: some View {
        SceneView(
            scene: load3DModel(from: modelUrl),
            options: [.allowsCameraControl, .autoenablesDefaultLighting]
        )
        .edgesIgnoringSafeArea(.all)
        .background(Color.red) // Background color for visibility
    }
    
    func load3DModel(from url: URL) -> SCNScene? {
        let scene = SCNScene()
        scene.background.contents = UIColor.gray // Set the scene background color to red
        
        // Download the model data
        downloadModel(from: url) { localURL, error in
            guard let localURL = localURL, error == nil else {
                print("Error downloading model: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let modelScene = try SCNScene(url: localURL, options: nil)
                let node = modelScene.rootNode.clone()
                
                printNodeHierarchy(node: node) // Print node hierarchy
                
                if node.childNodes.isEmpty {
                    print("Loaded node has no geometry")
                } else {
                    // Scale the node down significantly
                    node.scale = SCNVector3(0.2, 0.2, 0.2)
                    
                    let (min, max) = node.boundingBox
                    print("Model bounding box min: \(min), max: \(max)")
                    
                    node.position = SCNVector3(0, 0, 0) // Center it
                    scene.rootNode.addChildNode(node)
                    
                    // Add a camera to the scene
                    let cameraNode = SCNNode()
                    cameraNode.camera = SCNCamera()
                    cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
                    cameraNode.look(at: node.position)
                    scene.rootNode.addChildNode(cameraNode)
                }
            } catch {
                print("Error loading 3D model from local URL: \(localURL) - \(error.localizedDescription)")
            }
        }
        
        return scene
    }
    
    // Function to download the model
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
            
            // Define the permanent location for the downloaded file
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let permanentURL = documentsDirectory.appendingPathComponent("downloadedModel.usdz")
            
            do {
                // Check if a file already exists at the destination
                if fileManager.fileExists(atPath: permanentURL.path) {
                    // Remove the existing file
                    try fileManager.removeItem(at: permanentURL)
                }
                
                // Move the downloaded file to the permanent location
                try fileManager.moveItem(at: tempLocalUrl, to: permanentURL)
                completion(permanentURL, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }


    // Function to print the node hierarchy
    func printNodeHierarchy(node: SCNNode, indent: String = "") {
        print("\(indent)\(node.name ?? "Unnamed Node")")
        for child in node.childNodes {
            printNodeHierarchy(node: child, indent: indent + "  ")
            if let geometry = child.geometry {
                print("  Geometry found in child node: \(child.name ?? "Unnamed Child")")
            } else {
                print("  No geometry in child node: \(child.name ?? "Unnamed Child")")
            }
        }
    }
}
