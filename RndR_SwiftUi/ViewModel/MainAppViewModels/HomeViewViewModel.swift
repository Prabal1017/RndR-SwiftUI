import FirebaseFirestore
import FirebaseStorage
import Combine

class HomeViewViewModel: ObservableObject {
    @Published var categories: [Category] = []
    private var db = Firestore.firestore()
    
    init() {
        loadCategoriesFromUserDefaults()
        
        // Fetch categories from Firebase only if no local data is available
        if categories.isEmpty {
            print("fetching firebase data")
            fetchCategories()
            
        }
    }
    
    func fetchCategories() {
        db.collection("categories").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No categories found")
                return
            }
            
            self.categories = documents.compactMap { doc -> Category? in
                let category = try? doc.data(as: Category.self)
                print("Fetched category: \(String(describing: category))") // Debug print
                return category
            }
            
            // Save to UserDefaults
            self.saveCategoriesToUserDefaults(categories: self.categories)
        }
    }
    
    func deleteCategory(_ category: Category) {
        let db = Firestore.firestore()
        
        // Use the full image URL from category.categoryImage
        let storageRef = Storage.storage().reference(forURL: category.categoryImage)
        
        // First, delete the image from Firebase Storage
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image from storage: \(error.localizedDescription)")
                return
            }
            
            // Then, delete the category document from Firestore
            db.collection("categories").whereField("categoryName", isEqualTo: category.categoryName).getDocuments { snapshot, error in
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
                    db.collection("categories").document(document.documentID).delete { error in
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
