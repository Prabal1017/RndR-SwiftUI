//import SwiftUI
//import FirebaseStorage
//import FirebaseFirestore
//
//struct AddRoomView: View {
//    @Binding var isShowingAddRoomView: Bool
//    @State private var roomName = ""
//    @State private var selectedImage: UIImage?
//    @State private var showImagePicker = false
//    @State private var imageURL: String?
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Room Details")) {
//                    TextField("Enter room name", text: $roomName)
//                    
//                    Button(action: {
//                        showImagePicker = true
//                    }) {
//                        Text("Select Image")
//                    }
//                    
//                    if let selectedImage = selectedImage {
//                        Image(uiImage: selectedImage)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 200)
//                    }
//                }
//            }
//            .navigationTitle("New Room")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        isShowingAddRoomView = false
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        addCategory()
//                    }
//                    .disabled(roomName.isEmpty || selectedImage == nil)
//                }
//            }
//            .sheet(isPresented: $showImagePicker) {
//                ImagePicker(image: $selectedImage)
//                    .onDisappear {
//                        if selectedImage != nil {
//                            uploadImageToFirebase()
//                        }
//                    }
//            }
//        }
//    }
//    
//    private func uploadImageToFirebase() {
//        guard let image = selectedImage else { return }
//        let storage = Storage.storage().reference()
//        let imageRef = storage.child("categories/\(UUID().uuidString).jpg")
//        
//        if let imageData = image.jpegData(compressionQuality: 0.75) {
//            imageRef.putData(imageData, metadata: nil) { _, error in
//                if let error = error {
//                    print("Error uploading image: \(error)")
//                    return
//                }
//                imageRef.downloadURL { url, error in
//                    if let error = error {
//                        print("Error getting download URL: \(error)")
//                        return
//                    }
//                    self.imageURL = url?.absoluteString
//                }
//            }
//        }
//    }
//    
//    private func addCategory() {
//        guard !roomName.isEmpty, let imageURL = imageURL else { return }
//        
//        let db = Firestore.firestore()
//        let category = [
//            "categoryName": roomName,
//            "categoryImage": imageURL
//        ]
//        
//        db.collection("categories").addDocument(data: category) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//                return
//            }
//            print("Document added successfully")
//            //fetch new categories
//            HomeViewViewModel().fetchCategories()
//            //fetch new category names
//            RoomPlanViewViewModel().fetchCategoryNames()
//            
//            isShowingAddRoomView = false
//        }
//    }
//}



import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct AddRoomView: View {
    @Binding var isShowingAddRoomView: Bool
    @State private var roomName = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imageURL: String?
    @ObservedObject var viewModel: RoomPlanViewViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Room Details")) {
                    TextField("Enter room name", text: $roomName)
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Select Image")
                    }
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }
            }
            .navigationTitle("New Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isShowingAddRoomView = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isShowingAddRoomView = false
                    }
                    .disabled(roomName.isEmpty || selectedImage == nil)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil {
                            uploadImageToFirebase { imageURL in
                                guard let imageURL = imageURL else {
                                    print("Failed to get image URL")
                                    return
                                }
                                
                                // Now you can proceed to add the category with the imageURL
                                addCategory(imageURL: imageURL)
                            }
                        }
                    }
            }
        }
    }
    
    private func uploadImageToFirebase(completion: @escaping (String?) -> Void) {
        guard let image = selectedImage else {
            completion(nil)
            return
        }
        
        let storage = Storage.storage().reference()
        let imageRef = storage.child("categories/\(UUID().uuidString).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    completion(nil)
                    return
                }
                
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

    private func addCategory(imageURL: String) {
        guard !roomName.isEmpty else {
            print("Room name is empty.")
            return
        }
        
        let db = Firestore.firestore()
        let category = [
            "categoryName": roomName,
            "categoryImage": imageURL
        ]
        
        db.collection("categories").addDocument(data: category) { error in
            if let error = error {
                print("Error adding document: \(error)")
                return
            }
            print("Document added successfully")
            // Fetch new categories
            HomeViewViewModel().fetchCategories()
            // Fetch new category names
            RoomPlanViewViewModel().fetchCategoryNames()
            
            isShowingAddRoomView = false
        }
    }
}

