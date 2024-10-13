//
//  ProfileViewViewModel.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewViewModel: ObservableObject{
    init() {}
    
    @Published var user: User? = nil
    
    //MARK: - profile image upload
    // Function to upload profile image
        func uploadProfileImage(image: UIImage, completion: @escaping (Bool) -> Void) {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }

            let storageRef = Storage.storage().reference().child("users/\(currentUserId)/userImage.jpg")
            
            // Convert UIImage to Data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(false)
                return
            }
            
            // Upload the image to Firebase Storage
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // Once upload is complete, update the user's profile image URL in Firestore
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error fetching download URL: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    guard let downloadURL = url else {
                        completion(false)
                        return
                    }
                    
                    // Update the user's profile image URL in Firestore
                    self.updateUserProfileImageUrl(downloadURL.absoluteString) { success in
                        completion(success)
                    }
                }
            }
        }
        
        // Function to update user profile image URL in Firestore
        func updateUserProfileImageUrl(_ url: String, completion: @escaping (Bool) -> Void) {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(currentUserId)
            
            userRef.updateData(["profileImageUrl": url]) { error in
                if let error = error {
                    print("Error updating profile image URL: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    
    //MARK: - update logged in user details
    func updateUserDetails(name: String, email: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let userData: [String: Any] = [
            "name": name,
            "email": email
        ]
        
        Firestore.firestore().collection("users").document(userId).updateData(userData) { error in
            if let error = error {
                print("Error updating user: \(error.localizedDescription)")
                completion(false)
            } else {
                self.user?.name = name
                self.user?.email = email
                completion(true)
            }
        }
    }
    
    //MARK: - fetch current user
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("No data found.")
                    return
                }
                
                print("Fetched data: \(data)")
                
                if let timestamp = data["joined"] as? Timestamp {
                    let joinedDate = timestamp.dateValue()
                    
                    // Fetch the profile image URL, if it exists
                    let profileImageUrl = data["profileImageUrl"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.user = User(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            joined: timestamp, // Store the Timestamp directly
                            profileImageUrl: profileImageUrl // Add the profile image URL
                        )
                    }
                } else {
                    print("Timestamp not found in data.")
                    
                    // Fetch the profile image URL, if it exists
                    let profileImageUrl = data["profileImageUrl"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.user = User(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            joined: Timestamp(date: Date()), // Fallback if no Timestamp is present
                            profileImageUrl: profileImageUrl // Add the profile image URL
                        )
                    }
                }
            }
    }

    //MARK: - logout function
    func logOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
    }
    
    // MARK: - Close Account
    // Example of closing account with comprehensive data deletion
    func closeAccount(password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "auth", code: 404, userInfo: [NSLocalizedDescriptionKey: "No current user found."])))
            return
        }
        
        if password.isEmpty {
            completion(.failure(NSError(domain: "auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Password field is empty."])))
            return
        }
        
        guard let email = currentUser.email else {
            completion(.failure(NSError(domain: "auth", code: 404, userInfo: [NSLocalizedDescriptionKey: "No email found for the current user."])))
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        currentUser.reauthenticate(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let db = Firestore.firestore()
            let storage = Storage.storage()
            let userId = currentUser.uid
            let deleteGroup = DispatchGroup()
            
            // Delete user categories
            deleteGroup.enter()
            db.collection("categories").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching categories: \(error.localizedDescription)")
                } else if let documents = querySnapshot?.documents {
                    for document in documents {
                        db.collection("categories").document(document.documentID).delete { error in
                            if let error = error {
                                print("Error deleting category: \(error.localizedDescription)")
                            } else {
                                print("Category deleted: \(document.documentID)")
                            }
                        }
                    }
                }
                deleteGroup.leave()
            }
            
            // Delete user data from Firestore
            deleteGroup.enter()
            db.collection("users").document(userId).delete { error in
                if let error = error {
                    print("Error deleting user data: \(error.localizedDescription)")
                } else {
                    print("User data deleted.")
                }
                deleteGroup.leave()
            }
            
            // Delete user's files from Firebase Storage
            deleteGroup.enter()
            let storageRef = storage.reference().child("users/\(userId)/")
            storageRef.listAll { (result, error) in
                if let error = error {
                    print("Error listing files: \(error.localizedDescription)")
                    deleteGroup.leave() // Leave the group on error
                    return
                }
                
                // Safely unwrap the result
                guard let result = result else {
                    print("No files found for user.")
                    deleteGroup.leave() // Leave the group if there's no result
                    return
                }
                
                let deleteGroupStorage = DispatchGroup()
                for item in result.items {
                    deleteGroupStorage.enter()
                    item.delete { error in
                        if let error = error {
                            print("Error deleting file: \(error.localizedDescription)")
                        } else {
                            print("File deleted: \(item.name)")
                        }
                        deleteGroupStorage.leave()
                    }
                }
                
                // Notify when all files have been deleted
                deleteGroupStorage.notify(queue: .main) {
                    print("All files deleted from Storage.")
                    deleteGroup.leave()
                }
            }
            
            // Wait for all deletions to complete before deleting the user
            deleteGroup.notify(queue: .main) {
                // Now delete from Firebase Authentication
                currentUser.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        print("User successfully deleted.")
                        do {
                            try Auth.auth().signOut()
                            completion(.success(true))
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
}

