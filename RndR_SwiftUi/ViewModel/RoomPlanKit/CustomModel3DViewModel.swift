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
    func saveEditedModel(selectedNode: SCNNode?, progressHandler: @escaping (Double) -> Void, completion: @escaping (Bool) -> Void) {
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
            try scene.write(to: exportURL, options: nil, delegate: nil) // Export the scene
            print("Model exported to: \(exportURL)")
            uploadModel(to: exportURL, userId: userId, progressHandler: progressHandler) { success in
                completion(success) // Notify success or failure
            }
        } catch {
            print("Error exporting model: \(error.localizedDescription)")
            completion(false) // Notify failure
        }
    }

    private func uploadModel(to url: URL, userId: String, progressHandler: @escaping (Double) -> Void, completion: @escaping (Bool) -> Void) {
        let storageRef = Storage.storage().reference().child("users/\(userId)/roomModels/\(originalModelUrl.lastPathComponent)")

        if let modelData = try? Data(contentsOf: url) {
            let uploadTask = storageRef.putData(modelData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading model: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                print("Model successfully uploaded to Firebase.")
                completion(true) // Notify success
            }

            // Monitor the upload progress
            uploadTask.observe(.progress) { snapshot in
                let progress = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
                progressHandler(progress) // Call the progress handler with the current progress
                print("Upload progress: \(progress)")
            }
        } else {
            print("Failed to load model data.")
            completion(false)
        }
    }
}
