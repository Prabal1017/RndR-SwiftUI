////
////  RoomPlanViewViewModel.swift
////  RndR_SwiftUi
////
////  Created by Piyush saini on 16/09/24.
////
//
//import Foundation
//import FirebaseFirestore
//import FirebaseStorage
//
//class RoomPlanViewViewModel: ObservableObject{
//    func saveRoomData(_ room: Room) {
//        // Save room data to Firestore
//        let db = Firestore.firestore()
//        let roomData: [String: Any] = [
//            "id": room.id,
//            "roomName": room.roomName,
//            "roomType": room.roomType,
//            "imageUrl": room.imageUrl,
//            "modelUrl": room.modelUrl,
//            "timestamp": Timestamp()
//        ]
//
//        db.collection("rooms").addDocument(data: roomData) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                print("Document successfully added")
//            }
//        }
//    }
//
//    // Function to upload image to Firebase Storage
//    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
//        let storageRef = Storage.storage().reference().child("roomImages/\(UUID().uuidString).jpg")
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            completion(nil)
//            return
//        }
//
//        storageRef.putData(imageData, metadata: nil) { metadata, error in
//            if let error = error {
//                print("Error uploading image: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//
//            storageRef.downloadURL { url, error in
//                if let error = error {
//                    print("Error retrieving download URL: \(error.localizedDescription)")
//                    completion(nil)
//                } else {
//                    completion(url?.absoluteString)
//                }
//            }
//        }
//    }
//}


import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

class RoomPlanViewViewModel: ObservableObject {
    
    @Published var categoryNames: [String] = []
    @Published var recentRooms: [Room] = []
    
    // Function to save room data to Firestore under the roomType chosen
    func saveRoomData(_ room: Room) {
        let db = Firestore.firestore()
        let roomData: [String: Any] = [
            "id": room.id,
            "roomName": room.roomName,
            "roomType": room.roomType,
            "imageUrl": room.imageUrl,
            "modelUrl": room.modelUrl,
            "timestamp": Timestamp()
        ]
        
        db.collection("rooms")
            .document(room.roomType)
            .collection("roomDetails")
            .document(room.id)
            .setData(roomData) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document successfully added under \(room.roomType) collection")
                }
            }
    }
    
    // Function to upload image to Firebase Storage based on the roomType
    func uploadImage(_ image: UIImage, roomType: String, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("rooms/\(roomType)/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error retrieving download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    func fetchCategoryNames() {
        let db = Firestore.firestore()
        
        db.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                self.categoryNames = []
                return
            }
            
            let names = snapshot?.documents.compactMap { document in
                return document.data()["categoryName"] as? String
            } ?? []
            
            DispatchQueue.main.async {
                self.categoryNames = names
            }
        }
    }
    
    func fetchRecentRooms() {
        print("Fetching recent rooms")
        
        let db = Firestore.firestore()
        
        let categories: [String]
        
        if(categoryNames.isEmpty) {
            categories = ["Bathroom", "Dinning Room", "Kitchen", "Living Room", "Bedroom"]
        }
        else{
            categories = categoryNames
        }
        var allRooms: [Room] = []
        
        let dispatchGroup = DispatchGroup()
        
        for category in categories {
            dispatchGroup.enter()
            
            db.collection("rooms").document(category).collection("roomDetails")
                .order(by: "timestamp", descending: true)
                .limit(to: 5)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching rooms from \(category): \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }

                    if let documents = snapshot?.documents {
                        let rooms = documents.compactMap { document -> Room? in
                            let data = document.data()
                            
                            guard let id = document.documentID as String?,
                                  let roomName = data["roomName"] as? String,
                                  let roomType = data["roomType"] as? String,
                                  let imageUrl = data["imageUrl"] as? String,
                                  let modelUrl = data["modelUrl"] as? String,
                                  let timestamp = data["timestamp"] as? Timestamp else {
                                return nil
                            }

                            let roomImage = UIImage()

                            return Room(
                                id: id,
                                roomName: roomName,
                                roomType: roomType,
                                imageUrl: imageUrl,
                                image: roomImage,
                                modelUrl: modelUrl,
                                timestamp: timestamp
                            )
                        }
                        allRooms.append(contentsOf: rooms)
                    }

                    dispatchGroup.leave()
                }
        }

        dispatchGroup.notify(queue: .main) {
            self.recentRooms = allRooms.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
            if self.recentRooms.count > 5 {
                self.recentRooms = Array(self.recentRooms.prefix(5))
            }
            
//            print("Recent rooms: \(self.recentRooms)")
        }
    }
}
