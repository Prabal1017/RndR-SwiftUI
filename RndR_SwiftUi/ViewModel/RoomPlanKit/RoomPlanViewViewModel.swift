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
    
    // Published property to store fetched category names
    @Published var categoryNames: [String] = []
    
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
        
        // Save the room data inside the corresponding roomType collection
        db.collection("rooms")
            .document(room.roomType)  // RoomType as document
            .collection("roomDetails")  // Room details under that document
            .document(room.id)  // Use room ID for the document name
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
        // Create a reference to the storage location based on the roomType
        let storageRef = Storage.storage().reference().child("rooms/\(roomType)/\(UUID().uuidString).jpg")
        
        // Convert UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Retrieve the download URL for the uploaded image
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
    
    // Function to fetch categories from Firestore and store them in the shared array
    func fetchCategoryNames() {
        let db = Firestore.firestore()
        
        db.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                self.categoryNames = [] // Reset array if there's an error
                return
            }
            
            let names = snapshot?.documents.compactMap { document in
                return document.data()["categoryName"] as? String
            } ?? []
            
            DispatchQueue.main.async {
                self.categoryNames = names // Update the shared array with fetched names
            }
        }
    }
}
