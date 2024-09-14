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
