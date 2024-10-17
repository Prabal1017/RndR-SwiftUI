import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    init() {}
    
    //MARK: - register new user
    func register() {
        guard validate() else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else {
                print("Error creating user: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self?.insertUserRecord(id: userId)
            
            // Reset the local storage to have new user's recent rooms
            RoomPlanViewViewModel().handleUserChange()
        }
    }
    
    //MARK: - insert user records
    private func insertUserRecord(id: String) {
        let newUser = User(id: id, name: name, email: email, joined: Timestamp(date: Date())) // Use Firebase Timestamp to store the exact time
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary()) { error in
                if let error = error {
                    print("Error saving user data: \(error)")
                } else {
                    print("User data successfully saved")
                    // Call the method to create default categories for the new user
                    self.createDefaultCategories(for: id)
                }
            }
    }
    
    // MARK: - Create default Categories
    /// Method to create default categories for the user
    func createDefaultCategories(for userId: String) {
        let db = Firestore.firestore()
        
        // Define default categories with names and image URLs
        let defaultCategories: [(name: String, imageUrl: String)] = [
            (name: "Bathroom", imageUrl: "https://firebasestorage.googleapis.com/v0/b/rndr-a1b5f.appspot.com/o/Default_Categories_Image%2FBathroom.jpg?alt=media&token=6eace4fc-47a3-4510-9233-18366dadc5b3"),
            (name: "Dining Room", imageUrl: "https://firebasestorage.googleapis.com/v0/b/rndr-a1b5f.appspot.com/o/Default_Categories_Image%2FDiningRoom.jpg?alt=media&token=363454bc-11d2-44a6-8df5-58206262e765"),
            (name: "Kitchen", imageUrl: "https://firebasestorage.googleapis.com/v0/b/rndr-a1b5f.appspot.com/o/Default_Categories_Image%2FKitchen.jpg?alt=media&token=809a0c09-ccb6-465b-bbd3-598d362a2dca"),
            (name: "Living Room", imageUrl: "https://firebasestorage.googleapis.com/v0/b/rndr-a1b5f.appspot.com/o/Default_Categories_Image%2FLivingRoom.jpg?alt=media&token=cd566435-cc6a-4305-a0a3-b114f6ce73c4"),
            (name: "Bedroom", imageUrl: "https://firebasestorage.googleapis.com/v0/b/rndr-a1b5f.appspot.com/o/Default_Categories_Image%2FBedroom.jpg?alt=media&token=9c9f7cab-4bc7-4026-8c44-079a63087f68")
        ]
        
        // Check if categories already exist for the user
        db.collection("users")
            .document(userId)
            .collection("categories")  // Change to categories collection
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching categories: \(error.localizedDescription)")
                    return
                }
                
                // Check if categories exist
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("Categories already exist for user \(userId).")
                    return // Categories already exist; do not create them again
                }
                
                // Loop through default categories and add them to Firestore under the new user
                for category in defaultCategories {
                    let categoryData: [String: Any] = [
                        "categoryName": category.name,
                        "categoryImage": category.imageUrl // Include the image URL
                    ]
                    
                    db.collection("users")
                        .document(userId)
                        .collection("categories") // Save in categories collection
                        .document(category.name) // Use the category name as the document ID
                        .setData(categoryData) { error in
                            if let error = error {
                                print("Error adding category \(category.name): \(error.localizedDescription)")
                            } else {
                                print("Successfully added category: \(category.name)")
                            }
                        }
                }
            }
    }

    
    //MARK: - validation code
    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            return false
        }
        
        return isValidPassword(password)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{7,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
