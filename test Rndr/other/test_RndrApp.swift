//
//  test_RndrApp.swift
//  test Rndr
//
//  Created by Piyush saini on 11/09/24.
//

import SwiftUI
import RoomPlan

@main
struct test_RndrApp: App {
    var body: some Scene {
        WindowGroup {
            checkDeciveView()
        }
    }
}


@ViewBuilder
func checkDeciveView() -> some View {
    if RoomCaptureSession.isSupported{
        ContentView()
    } else {
        UnsupportedDeviceView()
    }
}
