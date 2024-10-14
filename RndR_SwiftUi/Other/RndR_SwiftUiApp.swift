//
//  RndR_SwiftUiApp.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import SwiftUI
import FirebaseCore
import RoomPlan

@main
struct RndR_SwiftUiApp: App {
    
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sessionSettings = SessionSettings()
    @StateObject var sceneManager = SceneManager()
    
    @StateObject var modelsViewModel = ModelViewModel()
    @StateObject var modelDeletionManager = ModelDeletionManager()
    
    @StateObject private var roomCaptureController = RoomCaptureController()
    
    init() {
        //        _ = RoominatorFileManager.shared
        
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(roomCaptureController)
                .environmentObject(placementSettings)
                .environmentObject(sessionSettings)
                .environmentObject(sceneManager)
                .environmentObject(modelsViewModel)
                .environmentObject(modelDeletionManager)
            //            checkDeciveView()
            
        }
    }
}


//@ViewBuilder
//func checkDeciveView() -> some View {
//    if RoomCaptureSession.isSupported{
//        StartScanView()
//    } else {
//        UnsupportedDeviceView()
//    }
//}
