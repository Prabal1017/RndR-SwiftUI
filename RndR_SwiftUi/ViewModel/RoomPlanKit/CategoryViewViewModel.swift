import Foundation
import FirebaseFirestore
import FirebaseStorage

class CategoryViewViewModel: ObservableObject {
    @Published var rooms: [Room] = []

    //MARK: fetch rooms based-on type
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

    //MARK: delete room
    func deleteRoom(_ room: Room, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let storage = Storage.storage()

        // Create references for the image and 3D model using their URLs
        let imageRef = storage.reference(forURL: room.imageUrl)
        let modelRef = storage.reference(forURL: room.modelUrl)

        print("image path - \(imageRef)")
        print("model path - \(modelRef)")

        // Delete the image
        imageRef.delete { error in
            if let error = error {
                print("Error deleting image: \(error.localizedDescription)")
                completion(false)
                return
            }

            // Delete the 3D model
            modelRef.delete { error in
                if let error = error {
                    print("Error deleting 3D model: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                // Delete the Firestore document
                db.collection("rooms")
                    .document(room.roomType)
                    .collection("roomDetails")
                    .document(room.id)
                    .delete { error in
                        if let error = error {
                            print("Error deleting Firestore document: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Successfully deleted room")
                            completion(true)
                            
                            // Fetch recent rooms only after deletion is successful
                            RoomPlanViewViewModel().fetchRoomsFromFirebase()
                        }
                    }
            }
        }
    }
}
