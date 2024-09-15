import SwiftUI
import RealityKit
import ARKit

struct ARViewDisplay: UIViewRepresentable {
    var modelUrl: String
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Load the model into the ARView
        loadModel(from: modelUrl, on: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func loadModel(from urlString: String, on arView: ARView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        print("Loading model from URL: \(url)")
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempModel.usdz")
        
        // Delete any existing file with the same name
        if FileManager.default.fileExists(atPath: tempURL.path) {
            do {
                try FileManager.default.removeItem(at: tempURL)
            } catch {
                print("Failed to remove existing file: \(error.localizedDescription)")
                return
            }
        }
        
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            if let error = error {
                print("Error downloading model: \(error.localizedDescription)")
                return
            }
            
            guard let location = location else {
                print("Download location is nil")
                return
            }
            
            do {
                try FileManager.default.moveItem(at: location, to: tempURL)
                DispatchQueue.main.async {
                    loadModelFromTempURL(tempURL, on: arView)
                }
            } catch {
                print("Failed to move downloaded model file: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    
    private func loadModelFromTempURL(_ url: URL, on arView: ARView) {
        print("Loading model from local file: \(url)")
        
        let entity: Entity
        do {
            let loadedEntity = try Entity.load(contentsOf: url)
            if let modelEntity = loadedEntity as? ModelEntity {
                entity = modelEntity
            } else {
                print("Loaded entity is not a ModelEntity. Adding as a generic Entity.")
                entity = loadedEntity
            }
            print("Successfully loaded entity.")
        } catch {
            print("Failed to load entity: \(error.localizedDescription)")
            return
        }
        
        // Create an anchor and add the entity to the ARView
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(entity)
        
        arView.scene.addAnchor(anchor)
        arView.scene.anchors.append(anchor)
        
        print("Entity successfully added to ARView.")
    }
}
