//
//  RoomDataModel.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 15/09/24.
//

import Foundation
import SwiftUI
import FirebaseCore

struct Room: Identifiable {
    var id: String
    var roomName: String
    var roomType: String
    var imageUrl: String
    var image: UIImage
    var modelUrl: String
    var timestamp: Timestamp
}

