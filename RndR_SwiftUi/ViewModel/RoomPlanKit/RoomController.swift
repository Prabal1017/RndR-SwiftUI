import RoomPlan
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import SwiftUI
import FirebaseFirestore

class RoomController: RoomCaptureViewDelegate {
    
    static var instance = RoomController()
    var captureView: RoomCaptureView
    var sessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    var finalResult: CapturedRoom?
    
    func encode(with coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    init() {
        captureView = RoomCaptureView(frame: .zero)
        captureView.delegate = self
    }
    
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
        return true
    }
    
    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
        finalResult = processedResult
    }
    
    //MARK: - delete room model
    func deleteRoomModel(from url: URL, completion: @escaping (Bool) -> Void) {
        // Create a reference to the file you want to delete
        let storageReference = Storage.storage().reference(forURL: url.absoluteString)
        
        // Delete the file
        storageReference.delete { error in
            if let error = error {
                // There was an error while deleting the file
                print("Error deleting 3D model from Firebase: \(error.localizedDescription)")
                completion(false)
            } else {
                // File deleted successfully
                print("3D model successfully deleted from Firebase Storage.")
                completion(true)
            }
        }
    }
    
    // MARK: - Upload Room Model
    func uploadRoomModel(completion: @escaping (URL?) -> Void) {
        // Ensure that finalResult is not nil
        guard let finalResult = finalResult else {
            print("No room data available") // Log if no data is available
            completion(nil)
            return
        }

        // Ensure the current user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            completion(nil)
            return
        }

        // Debugging: Print details of the captured room
        print("Captured Room Details:")
        print("Walls: \(finalResult.walls.count)")
        print("Doors: \(finalResult.doors.count)")
        print("Windows: \(finalResult.windows.count)")
        print("Openings: \(finalResult.openings.count)")
        print("Floors: \(finalResult.floors.count)")
        print("Objects: \(finalResult.objects.count)")
        print("Identifier: \(finalResult.identifier)")
        print("Version: \(finalResult.version)")

        // Generate a unique identifier for the room scan
        let roomUUID = UUID().uuidString

        // Export the scanned model to a temporary file (URL)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(roomUUID).usdz")

        do {
            // Export to the temporary file
            try finalResult.export(to: tempURL, exportOptions: .parametric)

            // Read data from the file to upload
            let roomModelData = try Data(contentsOf: tempURL)

            // Check the size of the data before upload
            print("Exported file size: \(roomModelData.count) bytes")

            // Define the Firebase Storage reference with the current user ID in the path
            let roomModelRef = Storage.storage().reference().child("users/\(currentUserId)/roomModels/\(roomUUID).usdz")

            // Upload the data to Firebase Storage
            roomModelRef.putData(roomModelData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading room model: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("Room model uploaded successfully!")
                    // Remove the temporary file after upload
                    try? FileManager.default.removeItem(at: tempURL)

                    // Retrieve the download URL
                    roomModelRef.downloadURL { downloadURL, error in
                        if let error = error {
                            print("Error retrieving download URL: \(error.localizedDescription)")
                            completion(nil)
                        } else {
                            print("Model uploaded successfully: \(downloadURL?.absoluteString ?? "No URL")")
                            completion(downloadURL)
                        }
                    }
                }
            }

        } catch {
            print("Error exporting room model: \(error.localizedDescription)")
            completion(nil)
        }
    }

    
    func startSession() {
        captureView.captureSession.run(configuration: sessionConfig)
    }
    
    func stopSession() {
        captureView.captureSession.stop()
    }
}

struct RoomCaptureViewRepresentable : UIViewRepresentable {
    
    func makeUIView(context: Context) -> RoomCaptureView{
        RoomController.instance.captureView
    }
    
    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
        
    }
}
