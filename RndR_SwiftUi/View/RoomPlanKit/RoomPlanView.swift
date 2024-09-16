//import SwiftUI
//import FirebaseStorage
//import RoomPlan
//import FirebaseFirestore
//
//struct RoomPlanView: View {
//    var roomController = RoomController.instance
//    @State private var doneScanning: Bool = false
//    @State private var exportURL: URL?
//    @State private var showForm: Bool = false
//    @State private var modelDownloadURL: String?
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                RoomCaptureViewRepresentable()
//                    .onAppear {
//                        roomController.startSession()
//                    }
//
//                VStack {
//                    Spacer()
//
//                    if !doneScanning {
//                        Button(action: {
//                            roomController.stopSession()
//                            exportRoomData()
//                        }, label: {
//                            Text("Done Scanning")
//                                .padding(10)
//                        })
//                        .buttonStyle(.borderedProminent)
//                        .cornerRadius(30)
//                    } else if let _ = modelDownloadURL {
//                        NavigationLink(destination: ARViewContainer(usdzURL: exportURL ?? URL(fileURLWithPath: ""))) {
//                            Text("Preview Model")
//                                .padding(10)
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .cornerRadius(30)
//                    }
//                }
//                .padding(.bottom, 10)
//                .sheet(isPresented: $showForm) {
//                    RoomDetailsFormView { room in
//                        saveRoomToFirebase(room)
//                    }
//                }
//            }
//        }
//    }
//
//    func exportRoomData() {
//        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("RoomCapture.usdz")
//        
//        do {
//            try roomController.finalResult?.export(to: tempURL, exportOptions: .parametric)
//            
//            // Upload to Firebase Storage
//            uploadModelToFirebase(tempURL) { downloadURL in
//                if let downloadURL = downloadURL {
//                    self.modelDownloadURL = downloadURL
//                    self.doneScanning = true
//                    self.showForm = true
//                } else {
//                    print("Error: Failed to get download URL")
//                }
//            }
//        } catch {
//            print("Error during export: \(error.localizedDescription)")
//        }
//    }
//    
//    func uploadModelToFirebase(_ fileURL: URL, completion: @escaping (String?) -> Void) {
//        let roomUUID = UUID().uuidString
//        let storageRef = Storage.storage().reference().child("roomModels/\(roomUUID).usdz")
//        
//        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
//            if let error = error {
//                print("Error uploading room model: \(error.localizedDescription)")
//                completion(nil)
//            } else {
//                storageRef.downloadURL { url, error in
//                    if let error = error {
//                        print("Error retrieving download URL: \(error.localizedDescription)")
//                        completion(nil)
//                    } else {
//                        completion(url?.absoluteString)
//                    }
//                }
//            }
//        }
//    }
//    
//    func saveRoomToFirebase(_ room: Room) {
//        guard let modelURL = modelDownloadURL else {
//            print("Error: Model URL is missing")
//            return
//        }
//        
//        var updatedRoom = room
//        updatedRoom.modelUrl = modelURL
//        
//        let db = Firestore.firestore()
//        let roomData: [String: Any] = [
//            "id": updatedRoom.id,
//            "roomName": updatedRoom.roomName,
//            "roomType": updatedRoom.roomType,
//            "imageUrl": updatedRoom.imageUrl,
//            "modelUrl": updatedRoom.modelUrl,
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
//}


import SwiftUI
import FirebaseFirestore

struct RoomPlanView: View {
    var roomController = RoomController.instance
    @State private var doneScanning: Bool = false
    @State private var exportURL: URL?
    @State private var showingRoomForm = false
    
    @StateObject private var viewModel = RoomPlanViewViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                RoomCaptureViewRepresentable()
                    .onAppear {
                        roomController.startSession()
                    }

                VStack {
                    Spacer()

                    if !doneScanning {
                        Button(action: {
                            roomController.stopSession()
                            roomController.uploadRoomModel { url in
                                if let url = url {
                                    doneScanning = true
                                    exportURL = url
                                    showingRoomForm = true
                                } else {
                                    print("Failed to upload model")
                                }
                            }
                        }, label: {
                            Text("Done Scanning")
                                .padding(10)
                        })
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(30)
                    } else if doneScanning {
                        NavigationLink(destination: ARViewContainer(usdzURL: exportURL!)) {
                            Text("Preview Model")
                                .padding(10)
                        }
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(30)
                    }
                }
                .padding(.bottom, 10)
                .sheet(isPresented: $showingRoomForm) {
                    RoomDetailsFormView(modelUrl: exportURL?.absoluteString ?? "") { room in
                            viewModel.saveRoomData(room)
                    }
                }
            }
        }
    }

//    func saveRoomData(_ room: Room) {
//        // Save room data to Firestore
//        let db = Firestore.firestore()
//        let roomData: [String: Any] = [
//            "id": room.id,
//            "roomName": room.roomName,
//            "roomType": room.roomType,
//            "imageUrl": room.imageUrl,
//            "modelUrl": room.modelUrl,
//            "timestamp": Timestamp()
//        ]
//        
//        db.collection("rooms").addDocument(data: roomData) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                print("Document successfully added")
//            }
//        }
//    }
}
