import RoomPlan
import SwiftUI

class RoomController :  RoomCaptureViewDelegate {
    
    static var instance = RoomController()
    var captureView  : RoomCaptureView
    var sessionConfig : RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    var finalResult : CapturedRoom?
    
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
        
        // Example: Export to USDZ without completion handler
        let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent("RoomCapture.usdz")
        
        do {
            try finalResult?.export(to: exportURL, exportOptions: .parametric)
            print("Room successfully exported to \(exportURL)")
        } catch {
            print("Error during export: \(error.localizedDescription)")
        }
    }


    
    //    to start scanning
    func startSession() {
        captureView.captureSession.run(configuration: sessionConfig)
    }
    
    //    to stop session
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
