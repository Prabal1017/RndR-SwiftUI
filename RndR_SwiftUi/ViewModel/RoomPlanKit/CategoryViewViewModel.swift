import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CategoryViewViewModel: ObservableObject {
    @Published var rooms: [Room] = []

    // MARK: - Fetch Rooms Based on Room Type
    /// Fetch rooms based on room type for the current user
    func fetchRooms(for roomType: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        // Ensure the user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            completion(false)
            return
        }
        
        // Fetch rooms from the user's specific path
        db.collection("users")
            .document(currentUserId)
            .collection("rooms")
            .document("roomDetails")
            .collection(roomType)
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
                            timestamp: timestamp // Pass the timestamp
                        )
                    } ?? []
                    print("Successfully fetched \(self?.rooms.count ?? 0) rooms")
                    completion(true)
                }
            }
    }


    // MARK: - Delete Room
    func deleteRoom(_ room: Room, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let storage = Storage.storage()

        // Ensure the user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            completion(false)
            return
        }

        // Create references for the image and 3D model using their URLs
        let imageRef = storage.reference(forURL: room.imageUrl)
        let modelRef = storage.reference(forURL: room.modelUrl)

        print("Image path - \(imageRef)")
        print("Model path - \(modelRef)")

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

                // Delete the Firestore document for the logged-in user
                db.collection("users")
                    .document(currentUserId)
                    .collection("rooms")
                    .document("roomDetails")
                    .collection(room.roomType)
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
    
    //MARK: - crop image to landscape view
    func cropImageToLandscape(_ image: UIImage) -> UIImage? {
        let width = image.size.width
        let height = image.size.height
        
        // Set desired aspect ratio (landscape: 4:3)
        let targetAspectRatio: CGFloat = 4.0 / 3.0
        var newSize: CGSize
        
        if width / height > targetAspectRatio {
            // Image is wider than target aspect ratio
            let newHeight = height
            let newWidth = newHeight * targetAspectRatio
            newSize = CGSize(width: newWidth, height: newHeight)
        } else {
            // Image is taller than target aspect ratio
            let newWidth = width
            let newHeight = newWidth / targetAspectRatio
            newSize = CGSize(width: newWidth, height: newHeight)
        }

        // Calculate the crop rectangle
        let xOffset = (width - newSize.width) / 2
        let yOffset = (height - newSize.height) / 2
        let cropRect = CGRect(x: xOffset, y: yOffset, width: newSize.width, height: newSize.height)
        
        // Crop the image to the new size
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        image.draw(in: CGRect(x: -cropRect.origin.x, y: -cropRect.origin.y, width: width, height: height))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return croppedImage
    }

    //MARK: - upload category image to firebase
    func uploadImageToFirebase(croppedImage: UIImage, completion: @escaping (String?) -> Void) {
        // Get the current logged-in user's UID from Firebase Authentication
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            completion(nil)
            return
        }

        let storage = Storage.storage().reference()
        
        // Store the image in a folder named after the user's UID
        let imageRef = storage.child("users/\(uid)/categories/\(UUID().uuidString).jpg")
        
        if let imageData = croppedImage.jpegData(compressionQuality: 0.75) {
            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    completion(nil)
                    return
                }
                
                // Get the download URL for the uploaded image
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error)")
                        completion(nil)
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
    
    
    //MARK: - adding category to firebase
    func addCategory(imageURL: String, roomName: String) {
        guard !roomName.isEmpty else {
            print("Room name is empty.")
            return
        }

        // Get the current logged-in user's UID from Firebase Authentication
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }

        let db = Firestore.firestore()

        // Define the category data
        let category = [
            "categoryName": roomName,
            "categoryImage": imageURL
        ]

        // Save the category under the current user's folder
        db.collection("users").document(uid).collection("categories").addDocument(data: category) { error in
            if let error = error {
                print("Error adding document: \(error)")
                return
            }
            print("Document added successfully")

            // Fetch new categories (if needed)
            HomeViewViewModel().fetchCategories()

            // Fetch new category names (if needed)
            RoomPlanViewViewModel().fetchCategoryNames()
        }
    }
}
