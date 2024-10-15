//
//  RndR_SwiftUiApp.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import SwiftUI
import FirebaseCore
import RoomPlan
import TipKit

@main
struct RndR_SwiftUiApp: App {
    
    @StateObject private var roomCaptureController = RoomCaptureController()
    
    init() {
        //        _ = RoominatorFileManager.shared
        
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(roomCaptureController)
            //            checkDeciveView()
                .task{
                    try? Tips.resetDatastore()
                    
                    try? Tips.configure([
                        .datastoreLocation(.applicationDefault)])
                }
            
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
