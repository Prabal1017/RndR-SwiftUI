////
////  RoomDataModel.swift
////  RndR_SwiftUi
////
////  Created by Piyush saini on 15/09/24.
////
//
//import Foundation
//import SwiftUI
//import FirebaseCore
//
//struct Room: Identifiable {
//    var id: String
//    var roomName: String
//    var roomType: String
//    var imageUrl: String
//    var image: UIImage
//    var modelUrl: String
//    var timestamp: Timestamp
//}
//


import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore // Ensure this import is present for Timestamp

struct Room: Identifiable {
    var id: String
    var roomName: String
    var roomType: String
    var imageUrl: String
    var image: UIImage? // Make image optional
    var modelUrl: String
    var timestamp: Timestamp

    // Add an initializer if needed
    init(id: String, roomName: String, roomType: String, imageUrl: String, image: UIImage? = nil, modelUrl: String, timestamp: Timestamp) {
        self.id = id
        self.roomName = roomName
        self.roomType = roomType
        self.imageUrl = imageUrl
        self.image = image
        self.modelUrl = modelUrl
        self.timestamp = timestamp
    }
}
