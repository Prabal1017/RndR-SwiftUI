//import SwiftUI
//import FirebaseFirestore
//
//struct RoomPlanView: View {
//    var roomController = RoomController.instance
//    @State private var doneScanning: Bool = false
//    @State private var exportURL: URL?
//    @State private var showingRoomForm = false
//    
//    @StateObject private var viewModel = RoomPlanViewViewModel()
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
//                            roomController.uploadRoomModel { url in
//                                if let url = url {
//                                    doneScanning = true
//                                    exportURL = url
//                                    showingRoomForm = true
//                                } else {
//                                    print("Failed to upload model")
//                                }
//                            }
//                        }, label: {
//                            Text("Done Scanning")
//                                .padding(10)
//                        })
//                        .buttonStyle(.borderedProminent)
//                        .cornerRadius(30)
//                    } else if doneScanning {
//                        NavigationLink(destination: ARViewContainer(usdzURL: exportURL!)) {
//                            Text("Preview Model")
//                                .padding(10)
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .cornerRadius(30)
//                    }
//                }
//                .padding(.bottom, 10)
//                .sheet(isPresented: $showingRoomForm) {
//                    RoomDetailsFormView(modelUrl: exportURL?.absoluteString ?? "") { room in
//                            viewModel.saveRoomData(room)
//                    }
//                    
//                    .presentationDetents([.medium])
//                }
//            }
//        }
//    }
//
////    func saveRoomData(_ room: Room) {
////        // Save room data to Firestore
////        let db = Firestore.firestore()
////        let roomData: [String: Any] = [
////            "id": room.id,
////            "roomName": room.roomName,
////            "roomType": room.roomType,
////            "imageUrl": room.imageUrl,
////            "modelUrl": room.modelUrl,
////            "timestamp": Timestamp()
////        ]
////        
////        db.collection("rooms").addDocument(data: roomData) { error in
////            if let error = error {
////                print("Error adding document: \(error)")
////            } else {
////                print("Document successfully added")
////            }
////        }
////    }
//}




import SwiftUI
import FirebaseFirestore

struct RoomPlanView: View {
    var roomController = RoomController.instance
    @State private var doneScanning: Bool = false
    @State private var exportURL: URL?
    @State private var showingRoomForm = false
    @State private var showingAlert = false
    @State private var isScanning: Bool = false  // State to track if scanning has started
    @State private var isUploading: Bool = false  // State to track if upload is in progress
    @Environment(\.dismiss) var dismiss  // Dismiss the current view
    
    @StateObject private var viewModel = RoomPlanViewViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                RoomCaptureViewRepresentable()
                    .onAppear {
                        roomController.startSession()
                        isScanning = true // Scanning starts here
                    }
                    .onDisappear {
                        isScanning = false // Ensure scanning is reset if view disappears
                        roomController.stopSession()
                    }

                VStack {
                    Spacer()

                    // Show the "Done Scanning" button only when scanning has started
                    if isScanning && !doneScanning {
                        Button(action: {
                            if !isUploading {
                                isUploading = true // Prevent further uploads
                                roomController.stopSession()
                                roomController.uploadRoomModel { url in
                                    if let url = url {
                                        // Log the URL to ensure it's valid
                                        print("Model uploaded successfully: \(url.absoluteString)")
                                        
                                        doneScanning = true
                                        exportURL = url
                                        showingRoomForm = true
                                    } else {
                                        // Log the failure to upload
                                        print("Model upload failed, no URL returned")
                                        // Show alert when no model is scanned
                                        showingAlert = true
                                    }
                                    isUploading = false // Allow further uploads after processing
                                }
                            }
                        }, label: {
                            Text("Done Scanning")
                                .padding(10)
                        })
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(30)
                        .disabled(isUploading) // Disable the button during upload
                    } else if doneScanning {
                        NavigationLink(destination: ARViewContainer(usdzURL: exportURL!)) {
                            Text("AR Preview")
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
                    .presentationDetents([.medium])
                }
                .alert("No Model Scanned", isPresented: $showingAlert) {
                    Button("Try Again") {
                        // Go back to the parent view
                        dismiss()  // This will navigate back to the parent view
                    }
                } message: {
                    Text("No 3D model was uploaded. Please try scanning the room again.")
                }
            }
        }
    }
}
