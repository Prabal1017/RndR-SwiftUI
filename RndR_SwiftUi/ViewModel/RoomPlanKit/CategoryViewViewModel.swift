////
////  CategoryViewViewModel.swift
////  RndR_SwiftUi
////
////  Created by Piyush saini on 16/09/24.
////
//
//import Foundation
//import FirebaseFirestore
//
//class CategoryViewViewModel: ObservableObject{
//    
//    @Published var rooms: [Room] = []
//    
//    func fetchRooms() {
//        let db = Firestore.firestore()
//        db.collection("rooms/").getDocuments { [self] snapshot, error in
//            if let error = error {
//                print("Error fetching rooms: \(error.localizedDescription)")
//            } else {
//                rooms = snapshot?.documents.compactMap { document in
//                    let data = document.data()
//                    return Room(
//                        id: document.documentID,
//                        roomName: data["roomName"] as? String ?? "",
//                        roomType: data["roomType"] as? String ?? "",
//                        imageUrl: data["imageUrl"] as? String ?? "",
//                        image: UIImage(), // Placeholder
//                        modelUrl: data["modelUrl"] as? String ?? ""
//                    )
//                } ?? []
//                print("Successfully fetched \(rooms.count) rooms")
//                print("rooms - \(rooms)")
//            }
//        }
//    }
//}

//
//import Foundation
//import FirebaseFirestore
//
//class CategoryViewViewModel: ObservableObject {
//    
//    @Published var rooms: [Room] = []
//    
//    // Function to fetch rooms based on the selected room type
//    func fetchRooms(for roomType: String) {
//        let db = Firestore.firestore()
//        
//        // Access the rooms based on the roomType (category) passed
//        db.collection("rooms")
//            .document(roomType)
//            .collection("roomDetails")
//            .getDocuments { [self] snapshot, error in
//                if let error = error {
//                    print("Error fetching rooms: \(error.localizedDescription)")
//                } else {
//                    rooms = snapshot?.documents.compactMap { document in
//                        let data = document.data()
//                        return Room(
//                            id: document.documentID,
//                            roomName: data["roomName"] as? String ?? "",
//                            roomType: data["roomType"] as? String ?? "",
//                            imageUrl: data["imageUrl"] as? String ?? "",
//                            image: UIImage(), // Placeholder
//                            modelUrl: data["modelUrl"] as? String ?? ""
//                        )
//                    } ?? []
//                    print("Successfully fetched \(rooms.count) rooms")
//                }
//            }
//    }
//}


import Foundation
import FirebaseFirestore

class CategoryViewViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    
    // Fetch rooms based on room type
    func fetchRooms(for roomType: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("rooms")
            .document(roomType)
            .collection("roomDetails")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching rooms: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self?.rooms = snapshot?.documents.compactMap { document in
                        let data = document.data()
                        
                        // Extract the timestamp field
                        guard let timestamp = data["timestamp"] as? Timestamp else {
                            return nil
                        }

                        return Room(
                            id: document.documentID,
                            roomName: data["roomName"] as? String ?? "",
                            roomType: data["roomType"] as? String ?? "",
                            imageUrl: data["imageUrl"] as? String ?? "",
                            image: UIImage(), // Placeholder for the image
                            modelUrl: data["modelUrl"] as? String ?? "",
                            timestamp: timestamp  // Pass the timestamp
                        )
                    } ?? []
                    print("Successfully fetched \(self?.rooms.count ?? 0) rooms")
                    completion(true)
                }
            }
    }
}
