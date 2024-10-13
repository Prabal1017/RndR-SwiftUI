import Foundation
import SceneKit
import FirebaseAuth
import FirebaseStorage

//class CustomModel3DViewModel: ObservableObject {
//    private var modelUrl: URL
//
//    init(modelUrl: URL) {
//        self.modelUrl = modelUrl
//    }
//
//    // Function to save the model to Firebase
//    func saveEditedModel() {
//        guard let userId = Auth.auth().currentUser?.uid else { return } // Get the current user ID
//        
//        let storageRef = Storage.storage().reference().child("users/\(userId)/roomModels/\(modelUrl.lastPathComponent)")
//        
//        // Convert your model into Data (e.g., .usdz or .obj format)
//        do {
//            let modelData = try Data(contentsOf: modelUrl)
//            let uploadTask = storageRef.putData(modelData, metadata: nil) { metadata, error in
//                if let error = error {
//                    print("Error uploading edited model: \(error.localizedDescription)")
//                    return
//                }
//                print("Edited Model successfully uploaded to Firebase.")
//            }
//
//            // Monitor the upload progress
//            uploadTask.observe(.progress) { snapshot in
//                let progress = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
//                print("Upload progress: \(progress)")
//            }
//        } catch {
//            print("Failed to load model data: \(error.localizedDescription)")
//        }
//    }
//}


class CustomModel3DViewModel: ObservableObject {
    private var originalModelUrl: URL

    init(originalModelUrl: URL) {
        self.originalModelUrl = originalModelUrl
    }

    // Function to save the edited model to Firebase
    func saveEditedModel(selectedNode: SCNNode?) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Get the current user ID
        
        // Create a new SCNScene to export the modified model
        let scene = SCNScene()
        
        if let node = selectedNode {
            // Clone the node to preserve its transformations
            let clonedNode = node.clone()
            scene.rootNode.addChildNode(clonedNode)
        }

        // Define the file path for exporting the modified model
        let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).usdz")

        // Export the scene to USDZ format
        do {
            try scene.write(to: exportURL, options: nil, delegate: nil, progressHandler: nil)
            print("Model exported to: \(exportURL)")
            uploadModel(to: exportURL, userId: userId)
        } catch {
            print("Error exporting model: \(error.localizedDescription)")
        }
    }

    private func uploadModel(to url: URL, userId: String) {
        // Use the original model's filename to overwrite it in Firebase
        let storageRef = Storage.storage().reference().child("users/\(userId)/roomModels/\(originalModelUrl.lastPathComponent)")

        // Convert the model file into Data
        if let modelData = try? Data(contentsOf: url) {
            let uploadTask = storageRef.putData(modelData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading model: \(error.localizedDescription)")
                    return
                }
                print("Model successfully uploaded to Firebase.")
            }

            // Monitor the upload progress
            uploadTask.observe(.progress) { snapshot in
                let progress = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
                print("Upload progress: \(progress)")
            }
        } else {
            print("Failed to load model data.")
        }
    }
}
