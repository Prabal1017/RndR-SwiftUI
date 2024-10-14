//import FirebaseFirestore
//import FirebaseAuth
//import FirebaseStorage
//import Combine
//
//class HomeViewViewModel: ObservableObject {
//    @Published var categories: [Category] = []
//    private var db = Firestore.firestore()
//    
//    init() {
//        loadCategoriesFromUserDefaults()
//        
//        // Fetch categories from Firebase only if no local data is available
//        if categories.isEmpty {
//            print("fetching firebase data")
//            fetchCategories()
//            
//        }
//    }
//    //MARK: - fetch categories
//    func fetchCategories() {
//        // Get the current logged-in user's UID
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("No user is currently logged in.")
//            return
//        }
//        
//        let db = Firestore.firestore()
//        
//        // Fetch categories from the current user's folder in Firestore
//        db.collection("users")
//            .document(uid) // Folder specific to the current user
//            .collection("categories")
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("Error fetching categories: \(error)")
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No categories found")
//                    return
//                }
//                
//                // Map Firestore documents to Category models
//                self.categories = documents.compactMap { doc -> Category? in
//                    let category = try? doc.data(as: Category.self)
//                    return category
//                }
//                
//                // Save fetched categories to UserDefaults (if needed)
//                self.saveCategoriesToUserDefaults(categories: self.categories)
//            }
//    }
//
//    //MARK: - delete categories
//    func deleteCategory(_ category: Category) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("No user is currently logged in.")
//            return
//        }
//        
//        let db = Firestore.firestore()
//        
//        // Get the storage reference for the image using the correct path
//        let storageRef = Storage.storage().reference(forURL: category.categoryImage)
//        
//        // First, delete the image from Firebase Storage
//        storageRef.delete { error in
//            if let error = error {
//                print("Error deleting image from storage: \(error.localizedDescription)")
//                return
//            }
//            
//            // Then, delete the category document from Firestore
//            db.collection("users")
//                .document(uid)
//                .collection("categories")
//                .whereField("categoryName", isEqualTo: category.categoryName)
//                .getDocuments { snapshot, error in
//                    if let error = error {
//                        print("Error fetching documents: \(error.localizedDescription)")
//                        return
//                    }
//                    
//                    guard let documents = snapshot?.documents, !documents.isEmpty else {
//                        print("No documents found for category \(category.categoryName)")
//                        return
//                    }
//                    
//                    // Delete all documents that match the category name
//                    for document in documents {
//                        db.collection("users")
//                            .document(uid)
//                            .collection("categories")
//                            .document(document.documentID)
//                            .delete { error in
//                                if let error = error {
//                                    print("Error deleting category: \(error.localizedDescription)")
//                                } else {
//                                    print("Category and image deleted successfully")
//                                }
//                            }
//                    }
//                }
//        }
//    }
//    
//    private func saveCategoriesToUserDefaults(categories: [Category]) {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(categories) {
//            UserDefaults.standard.set(encoded, forKey: "savedCategories")
//        }
//    }
//    
//    func loadCategoriesFromUserDefaults() {
//        if let savedCategories = UserDefaults.standard.object(forKey: "savedCategories") as? Data {
//            let decoder = JSONDecoder()
//            if let loadedCategories = try? decoder.decode([Category].self, from: savedCategories) {
//                self.categories = loadedCategories
//            }
//        }
//    }
//}



import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Combine

class HomeViewViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var allRooms: [Room] = [] // Array to store all rooms
    private var db = Firestore.firestore()
    
    init() {
        loadCategoriesFromUserDefaults()
        
        // Fetch categories from Firebase only if no local data is available
        if categories.isEmpty {
            print("fetching firebase data")
            fetchCategories()
        }
    }
    
    //MARK: - fetch categories
    func fetchCategories() {
        // Get the current logged-in user's UID
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Fetch categories from the current user's folder in Firestore
        db.collection("users")
            .document(uid) // Folder specific to the current user
            .collection("categories")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching categories: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No categories found")
                    return
                }
                
                // Map Firestore documents to Category models
                self.categories = documents.compactMap { doc -> Category? in
                    let category = try? doc.data(as: Category.self)
                    return category
                }
                
                // Save fetched categories to UserDefaults (if needed)
                self.saveCategoriesToUserDefaults(categories: self.categories)
                
                // Fetch rooms for each category after fetching categories
                self.fetchAllRoomsForCategories()
            }
    }
    
    // MARK: - Fetch rooms for all categories
    func fetchAllRoomsForCategories() {
        // Get the current logged-in user's UID
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }

        let db = Firestore.firestore()

        for category in categories {
            db.collection("users")
                .document(uid)
                .collection("rooms")
                .document("roomDetails")
                .collection(category.categoryName) // Fetch rooms for each category
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching rooms for category \(category.categoryName): \(error)")
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("No rooms found in category \(category.categoryName)")
                        return
                    }

                    // Map Firestore documents to Room models manually
                    let fetchedRooms = documents.compactMap { doc -> Room? in
                        let data = doc.data() // Get document data as a dictionary
                        guard let roomName = data["roomName"] as? String,
                              let roomType = data["roomType"] as? String,
                              let imageUrl = data["imageUrl"] as? String,
                              let modelUrl = data["modelUrl"] as? String,
                              let timestamp = data["timestamp"] as? Timestamp else {
                            print("Error decoding document ID: \(doc.documentID)")
                            return nil // Skip this document if any field is missing or incorrect
                        }

                        // Create Room instance using the retrieved data
                        return Room(
                            id: doc.documentID, // Use the document ID
                            roomName: roomName,
                            roomType: roomType,
                            imageUrl: imageUrl,
                            image: nil, // Set image to nil
                            modelUrl: modelUrl,
                            timestamp: timestamp
                        )
                    }

                    DispatchQueue.main.async {
                        self.allRooms.append(contentsOf: fetchedRooms)
//                        print("Fetched rooms for category \(category.categoryName): \(fetchedRooms)")
//                        print("Updated all rooms: \(self.allRooms)") // Log updated allRooms
                    }
                }
        }
    }


    //MARK: - delete categories
    func deleteCategory(_ category: Category) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Get the storage reference for the image using the correct path
        let storageRef = Storage.storage().reference(forURL: category.categoryImage)
        
        // First, delete the image from Firebase Storage
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image from storage: \(error.localizedDescription)")
                return
            }
            
            // Then, delete the category document from Firestore
            db.collection("users")
                .document(uid)
                .collection("categories")
                .whereField("categoryName", isEqualTo: category.categoryName)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        print("No documents found for category \(category.categoryName)")
                        return
                    }
                    
                    // Delete all documents that match the category name
                    for document in documents {
                        db.collection("users")
                            .document(uid)
                            .collection("categories")
                            .document(document.documentID)
                            .delete { error in
                                if let error = error {
                                    print("Error deleting category: \(error.localizedDescription)")
                                } else {
                                    print("Category and image deleted successfully")
                                }
                            }
                    }
                }
        }
    }
    
    private func saveCategoriesToUserDefaults(categories: [Category]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "savedCategories")
        }
    }
    
    func loadCategoriesFromUserDefaults() {
        if let savedCategories = UserDefaults.standard.object(forKey: "savedCategories") as? Data {
            let decoder = JSONDecoder()
            if let loadedCategories = try? decoder.decode([Category].self, from: savedCategories) {
                self.categories = loadedCategories
            }
        }
    }
}
