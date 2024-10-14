//
//  RoomScanViews.swift
//  ForReal Demo
//
//  Created by Vatsal Patel  on 8/17/24.
//

import Foundation
import SwiftUI
import RoomPlan

//struct CameraCaptureView: UIViewRepresentable {
//    @Environment(RoomCaptureController.self) private var captureController
//
//    func makeUIView(context: Context) -> some UIView {
//        captureController.roomCaptureView
//    }
//
//    func updateUIView(_ uiView: UIViewType, context: Context) {}
//}

struct RoomScanningView: View {
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

                VStack {
                    Spacer()

                    // Show the "Done Scanning" button only when scanning has started
                    if isScanning && !doneScanning {
                        Button(action: {
                            if roomController.finalResult != nil {  // Ensure finalResult is ready
                                if !isUploading {
                                    isUploading = true // Prevent further uploads
                                    roomController.stopSession()
                                    roomController.uploadRoomModel { url in
                                        if let url = url {
                                            print("Model uploaded successfully: \(url.absoluteString)")
                                            doneScanning = true
                                            exportURL = url
                                            showingRoomForm = true
                                        } else {
                                            print("Model upload failed, no URL returned")
                                            showingAlert = true
                                        }
                                        isUploading = false // Allow further uploads after processing
                                    }
                                }
                            } else {
                                print("Room capture not yet complete.")
                                showingAlert = true // Show alert if scan is not complete
                            }
                        }, label: {
                            Text("Done Scanning")
                                .padding(10)
                        })
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(30)
                        .disabled(isUploading) // Disable the button during upload
                    }
                    else if doneScanning {
                        NavigationLink(destination: FileDetailView(fileName: "recent", modelURL: exportURL!)) {
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
                        viewModel.fetchRoomsFromFirebase()
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
            .onAppear {
                print("RoomScanningView appeared")
                roomController.startSession()
                isScanning = true
            }
            .onDisappear {
                print("RoomScanningView disappeared")
                isScanning = false
                roomController.stopSession()
            }
        }
    }
}


struct ScanNewRoomView: View {
    @Environment(RoomCaptureController.self) private var captureController
    
    var body: some View {
        NavigationStack {
            VStack {
                
                VStack{
                    Image("roomIcon2")
                        .resizable()
                        .frame(width: 140, height: 140)
                    Text("Get ready to scan your room")
                        .font(.title)
                        .bold()
                    
                    Text("Make sure to scan the room by pointing the camera at all surfaces.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    NavigationLink(destination: RoomScanningView()) {
                        Text("Start Scanning")
                            .padding(10)
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(30)
                }
                .background(.thickMaterial)
                .cornerRadius(10)
                .padding()
//
                
                VStack{
                    Text("Get ready to place objects")
                        .font(.title)
                        .bold()
                    
                    Text("Place objects in real world whereever you want.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    NavigationLink(destination: ARPlaceObjectMainView()) {
                        Text("Start Placing")
                            .padding(10)
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(30)
                }
                .background(.thickMaterial)
                .cornerRadius(10)
                .padding()
            }
        }
    }
}
