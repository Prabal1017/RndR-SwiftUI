//import RoomPlan
//import FirebaseCore
//import FirebaseStorage
//import SwiftUI
//import FirebaseFirestore
//
//class RoomController :  RoomCaptureViewDelegate {
//    
//    static var instance = RoomController()
//    var captureView  : RoomCaptureView
//    var sessionConfig : RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
//    var finalResult : CapturedRoom?
//    
//    func encode(with coder: NSCoder) {
//        fatalError("Not Needed")
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("Not Needed")
//    }
//    
//    init() {
//        captureView = RoomCaptureView(frame: .zero)
//        captureView.delegate = self
//    }
//    
//    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
//        return true
//    }
//    
//    
//    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
//        finalResult = processedResult
//        
//        // Generate a unique identifier for the room scan
//        let roomUUID = UUID().uuidString
//        
//        // Export the scanned model to a temporary file (URL)
//        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(roomUUID).usdz")
//        
//        do {
//            // Export to the temporary file
//            try finalResult?.export(to: tempURL, exportOptions: .parametric)
//            
//            // Check if the file exists and has data
//            guard FileManager.default.fileExists(atPath: tempURL.path),
//                  let roomModelData = try? Data(contentsOf: tempURL) else {
//                print("Error: File does not exist or is empty at \(tempURL.path)")
//                return
//            }
//
//            // Define the Firebase Storage reference
//            let roomModelRef = Storage.storage().reference().child("roomModels/\(roomUUID).usdz")
//
//            // Upload the data to Firebase Storage
//            roomModelRef.putData(roomModelData, metadata: nil) { metadata, error in
//                if let error = error {
//                    print("Error uploading room model: \(error.localizedDescription)")
//                } else {
//                    print("Room model uploaded successfully!")
//                    // Optionally, remove the temporary file after upload
//                    try? FileManager.default.removeItem(at: tempURL)
//                    
//                    // Optionally save the URL to Firestore
//                    roomModelRef.downloadURL { downloadURL, error in
//                        if let error = error {
//                            print("Error retrieving download URL: \(error.localizedDescription)")
//                        } else if let downloadURL = downloadURL {
//                            self.saveToFirestore(downloadURL: downloadURL.absoluteString)
//                        }
//                    }
//                }
//            }
//            
//        } catch {
//            print("Error exporting room model: \(error.localizedDescription)")
//        }
//    }
//
//
//    func saveToFirestore(downloadURL: String) {
//        let db = Firestore.firestore()
//        let roomData: [String: Any] = [
//            "url": downloadURL,
//            "timestamp": Timestamp()
//        ]
//        
//        db.collection("roomModels").addDocument(data: roomData) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                print("Document successfully added")
//            }
//        }
//    }
//
//
//
//
//    
//    //    to start scanning
//    func startSession() {
//        captureView.captureSession.run(configuration: sessionConfig)
//    }
//    
//    //    to stop session
//    func stopSession() {
//        captureView.captureSession.stop()
//    }
//    
//}


//
//
//
//import RoomPlan
////import FirebaseCore
//import FirebaseStorage
//import SwiftUI
//import FirebaseFirestore
//
//class RoomController : RoomCaptureViewDelegate {
//    
//    static var instance = RoomController()
//    var captureView: RoomCaptureView
//    var sessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
//    var finalResult: CapturedRoom?
//    
//    func encode(with coder: NSCoder) {
//        fatalError("Not Needed")
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("Not Needed")
//    }
//    
//    init() {
//        captureView = RoomCaptureView(frame: .zero)
//        captureView.delegate = self
//    }
//    
//    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
//        return true
//    }
//    
//    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
//        finalResult = processedResult
//    }
//    
//    func saveRoomModel() {
//        guard let finalResult = finalResult else {
//            print("No room model available to save.")
//            return
//        }
//        
//        // Generate a unique identifier for the room scan
//        let roomUUID = UUID().uuidString
//        
//        // Export the scanned model to a temporary file (URL)
//        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(roomUUID).usdz")
//        
//        do {
//            // Export to the temporary file
//            try finalResult.export(to: tempURL, exportOptions: .parametric)
//            
//            // Check if the file exists and has data
//            guard FileManager.default.fileExists(atPath: tempURL.path),
//                  let roomModelData = try? Data(contentsOf: tempURL) else {
//                print("Error: File does not exist or is empty at \(tempURL.path)")
//                return
//            }
//
//            // Define the Firebase Storage reference
//            let roomModelRef = Storage.storage().reference().child("roomModels/\(roomUUID).usdz")
//
//            // Upload the data to Firebase Storage
//            roomModelRef.putData(roomModelData, metadata: nil) { metadata, error in
//                if let error = error {
//                    print("Error uploading room model: \(error.localizedDescription)")
//                } else {
//                    print("Room model uploaded successfully!")
//                    // Optionally, remove the temporary file after upload
//                    try? FileManager.default.removeItem(at: tempURL)
//                    
//                    // Optionally save the URL to Firestore
//                    roomModelRef.downloadURL { downloadURL, error in
//                        if let error = error {
//                            print("Error retrieving download URL: \(error.localizedDescription)")
//                        } else if let downloadURL = downloadURL {
//                            self.saveToFirestore(downloadURL: downloadURL.absoluteString)
//                        }
//                    }
//                }
//            }
//            
//        } catch {
//            print("Error exporting room model: \(error.localizedDescription)")
//        }
//    }
//
//    func saveToFirestore(downloadURL: String) {
//        let db = Firestore.firestore()
//        let roomData: [String: Any] = [
//            "url": downloadURL,
//            "timestamp": Timestamp()
//        ]
//        
//        db.collection("roomModels").addDocument(data: roomData) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                print("Document successfully added")
//            }
//        }
//    }
//
//    // Start scanning
//    func startSession() {
//        captureView.captureSession.run(configuration: sessionConfig)
//    }
//    
//    // Stop session
//    func stopSession() {
//        captureView.captureSession.stop()
//    }
//}
//
//
//
//

struct RoomCaptureViewRepresentable : UIViewRepresentable {
    
    func makeUIView(context: Context) -> RoomCaptureView{
        RoomController.instance.captureView
    }
    
    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
        
    }
}




import RoomPlan
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

    func uploadRoomModel(completion: @escaping (URL?) -> Void) {
        guard let finalResult = finalResult else {
            print("No room data available")
            completion(nil)
            return
        }
        
        // Generate a unique identifier for the room scan
        let roomUUID = UUID().uuidString
        
        // Export the scanned model to a temporary file (URL)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(roomUUID).usdz")
        
        do {
            // Export to the temporary file
            try finalResult.export(to: tempURL, exportOptions: .parametric)
            
            // Read data from the file to upload
            let roomModelData = try Data(contentsOf: tempURL)
            
            // Define the Firebase Storage reference
            let roomModelRef = Storage.storage().reference().child("roomModels/\(roomUUID).usdz")
            
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
