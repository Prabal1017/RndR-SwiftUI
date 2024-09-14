//import SwiftUI
//import RoomPlan
//import RealityKit
//import ARKit
//import QuickLook
//
//struct RoomPlanView: View {
//    var roomController = RoomController.instance
//    @State private var doneScanning: Bool = false
//    @State private var exportURL: URL?
//
//    var body: some View {
//        ZStack {
//            RoomCaptureViewRepresentable()
//                .onAppear {
//                    roomController.startSession()
//                }
//
//            VStack {
//                Spacer()
//
//                if doneScanning == false {
//                    Button(action: {
//                        roomController.stopSession()
//                        exportRoomData()
//                    }, label: {
//                        Text("Done Scanning")
//                            .padding(10)
//                    })
//                    .buttonStyle(.borderedProminent)
//                    .cornerRadius(30)
//                } else if let url = exportURL {
//                    NavigationLink(destination: QuickLookPreview(url: url)) {
//                        Text("Preview Model")
//                            .padding(10)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .cornerRadius(30)
//                }
//            }
//            .padding(.bottom, 10)
//        }
//    }
//
//    func exportRoomData() {
//        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("RoomCapture.usdz")
//
//        do {
//            try roomController.finalResult?.export(to: tempURL, exportOptions: .parametric)
//            exportURL = tempURL
//            doneScanning = true
//            print("Room successfully exported to \(tempURL)")
//
//            // Check if the file exists
//            if FileManager.default.fileExists(atPath: tempURL.path) {
//                print("File exists at \(tempURL.path)")
//            } else {
//                print("File does not exist at \(tempURL.path)")
//            }
//        } catch {
//            print("Error during export: \(error.localizedDescription)")
//        }
//    }
//}
//
//
//// AR Model View to display USDZ in AR
//struct ARModelView: View {
//    var usdzURL: URL
//    
//    var body: some View {
//        ARViewContainer(usdzURL: usdzURL)
//            .edgesIgnoringSafeArea(.all)
//    }
//}
//
//struct ARViewContainer: UIViewRepresentable {
//    var usdzURL: URL
//    
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//        
//        // Try to load the USDZ model into the ARView
//        do {
//            let modelEntity = try Entity.load(contentsOf: usdzURL)
//            let anchorEntity = AnchorEntity(world: [0, 0, 0])
//            anchorEntity.addChild(modelEntity)
//            arView.scene.addAnchor(anchorEntity)
//        } catch {
//            print("Failed to load model: \(error.localizedDescription)")
//        }
//        
//        // Enable AR Plane detection
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal, .vertical]
//        arView.session.run(config)
//        
//        return arView
//    }
//    
//    func updateUIView(_ uiView: ARView, context: Context) {}
//}
//
//// QuickLook Preview for USDZ models (for testing)
//struct QuickLookPreview: UIViewControllerRepresentable {
//    var url: URL
//
//    func makeUIViewController(context: Context) -> QLPreviewController {
//        let previewController = QLPreviewController()
//        previewController.dataSource = context.coordinator
//        return previewController
//    }
//
//    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, QLPreviewControllerDataSource {
//        var parent: QuickLookPreview
//
//        init(_ parent: QuickLookPreview) {
//            self.parent = parent
//        }
//
//        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//            return 1
//        }
//
//        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//            return parent.url as NSURL
//        }
//    }
//}
//
//
//#Preview {
//    RoomPlanView()
//}


import SwiftUI
import RoomPlan

struct RoomPlanView: View {
    var roomController = RoomController.instance
    @State private var doneScanning: Bool = false
    @State private var exportURL: URL?

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
                            exportRoomData()
                        }, label: {
                            Text("Done Scanning")
                                .padding(10)
                        })
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(30)
                    } else if let url = exportURL {
                        NavigationLink(destination: ARViewContainer(usdzURL: url)) {
                            Text("Preview Model")
                                .padding(10)
                        }
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(30)
                    }
                }
                .padding(.bottom, 10)
            }
        }
    }

    func exportRoomData() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("RoomCapture.usdz")

        do {
            try roomController.finalResult?.export(to: tempURL, exportOptions: .parametric)
            exportURL = tempURL
            doneScanning = true
            print("Room successfully exported to \(tempURL)")

            // Check if the file exists
            if FileManager.default.fileExists(atPath: tempURL.path) {
                print("File exists at \(tempURL.path)")
            } else {
                print("File does not exist at \(tempURL.path)")
            }
        } catch {
            print("Error during export: \(error.localizedDescription)")
        }
    }
}
