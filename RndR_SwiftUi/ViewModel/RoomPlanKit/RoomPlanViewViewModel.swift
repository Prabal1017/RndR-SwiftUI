import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

class RoomPlanViewViewModel: ObservableObject {
    
    @Published var categoryNames: [String] = []
    @Published var recentRooms: [Room] = []
    
    // MARK: - Save Room Data to Firestore
    func saveRoomData(_ room: Room) {
        // Ensure the user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }
        
        let db = Firestore.firestore()
        
        // Prepare the room data
        let roomData: [String: Any] = [
            "id": room.id,
            "roomName": room.roomName,
            "roomType": room.roomType,
            "imageUrl": room.imageUrl,
            "modelUrl": room.modelUrl,
            "timestamp": Timestamp()
        ]
        
        // Save the data to the user's specific Firestore path
        db.collection("users")
            .document(currentUserId)
            .collection("rooms")
            .document("roomDetails")
            .collection(room.roomType)  // Further categorizing by room type if needed
            .document(room.id)
            .setData(roomData) { error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                } else {
                    print("Document successfully added under user's rooms collection")
    //                self.updateLocalStorage(with: room) // Update local storage if necessary
                    self.fetchRoomsFromFirebase()
                }
            }
    }

    
    // MARK: - Upload Image to Firebase Storage
    func uploadImage(_ image: UIImage, roomType: String, completion: @escaping (String?) -> Void) {
        // Ensure the user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            completion(nil)
            return
        }

        // Create a reference to Firebase Storage with the user's ID in the path
        let storageRef = Storage.storage().reference().child("users/\(currentUserId)/roomsImage/\(UUID().uuidString).jpg")
        
        // Convert the image to JPEG data with compression
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
                    // Return the download URL as a string
                    completion(url?.absoluteString)
                }
            }
        }
    }

    
    // MARK: - Fetch Category Names
    func fetchCategoryNames() {
        // Ensure the user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            self.categoryNames = []
            return
        }

        let db = Firestore.firestore()
        
        // Fetch categories from the path users/{currentUserId}/categories
        db.collection("users").document(currentUserId).collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                self.categoryNames = []
                return
            }
            
            let names = snapshot?.documents.compactMap { document in
                return document.data()["categoryName"] as? String
            } ?? []
            
            // Update categoryNames on the main thread
            DispatchQueue.main.async {
                self.categoryNames = names
            }
        }
    }

    
    // MARK: - Fetch Recent Rooms (with Local Storage)
    func fetchRecentRooms() {
        if let localRooms = getRoomsFromLocalStorage(), !localRooms.isEmpty {
            print("Loading recent rooms from local storage")
            self.recentRooms = localRooms
            return
        }
        
        print("Fetching recent rooms from Firebase")
        fetchRoomsFromFirebase()
    }
    
    // MARK: - Fetch Rooms from Firebase
    func fetchRoomsFromFirebase() {
        let db = Firestore.firestore()
        
        // Ensure the user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }
        
        let categories: [String]
        
        if(categoryNames.isEmpty) {
            categories = ["Bedroom", "Dining Room", "Kitchen", "Living Room", "Bathroom"]
        } else {
            categories = categoryNames
        }
        
        var allRooms: [Room] = []
        
        let dispatchGroup = DispatchGroup()
        
        for category in categories {
            dispatchGroup.enter()
            
            // Fetch rooms from the user's specific Firestore path
            db.collection("users")
                .document(currentUserId)
                .collection("rooms")
                .document("roomDetails")
                .collection(category)
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
            // Sort and limit the fetched rooms
            self.recentRooms = allRooms.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
            if self.recentRooms.count > 5 {
                self.recentRooms = Array(self.recentRooms.prefix(5))
            }
            
            print("Storing recent rooms to local storage")
            // Overwrite the local storage with the new recent rooms
            self.storeRoomsToLocalStorage(self.recentRooms)
        }
    }

    // MARK: - Local Storage Helper Methods

    // Save rooms to local storage (will overwrite existing data)
    private func storeRoomsToLocalStorage(_ rooms: [Room]) {
        let roomDicts = rooms.map { room in
            return [
                "id": room.id,
                "roomName": room.roomName,
                "roomType": room.roomType,
                "imageUrl": room.imageUrl,
                "modelUrl": room.modelUrl,
                // Convert timestamp to a number (storing seconds)
                "timestamp": NSNumber(value: room.timestamp.seconds)
            ] as [String: Any]
        }
        
        // This will overwrite any existing "recentRooms" data
        UserDefaults.standard.set(roomDicts, forKey: "recentRooms")
    }

    // Retrieve rooms from local storage
    private func getRoomsFromLocalStorage() -> [Room]? {
        guard let roomDicts = UserDefaults.standard.array(forKey: "recentRooms") as? [[String: Any]] else {
            return nil
        }
        
        let rooms = roomDicts.compactMap { dict -> Room? in
            guard let id = dict["id"] as? String,
                  let roomName = dict["roomName"] as? String,
                  let roomType = dict["roomType"] as? String,
                  let imageUrl = dict["imageUrl"] as? String,
                  let modelUrl = dict["modelUrl"] as? String,
                  let timestampSeconds = dict["timestamp"] as? NSNumber else {
                return nil
            }
            
            // Recreate the FIRTimestamp from the stored seconds
            let timestamp = Timestamp(seconds: Int64(timestampSeconds.intValue), nanoseconds: 0)
            let roomImage = UIImage() // Placeholder, imageUrl will be used to load actual image
            
            return Room(id: id, roomName: roomName, roomType: roomType, imageUrl: imageUrl, image: roomImage, modelUrl: modelUrl, timestamp: timestamp)
        }
        
        return rooms
    }

    // Update local storage when a new room is added
    private func updateLocalStorage(with room: Room) {
        var currentRooms = getRoomsFromLocalStorage() ?? []
        currentRooms.insert(room, at: 0) // Add the new room at the top
        
        if currentRooms.count > 5 {
            currentRooms = Array(currentRooms.prefix(5)) // Keep only the latest 5 rooms
        }
        
        storeRoomsToLocalStorage(currentRooms)
    }
}
