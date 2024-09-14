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
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
            checkDeciveView()
        }
    }
}

@ViewBuilder
func checkDeciveView() -> some View {
    if RoomCaptureSession.isSupported{
        StartScanView()
    } else {
        UnsupportedDeviceView()
    }
}
