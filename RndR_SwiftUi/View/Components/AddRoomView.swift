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


//
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
//    @ObservedObject var viewModel: RoomPlanViewViewModel
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
//                        isShowingAddRoomView = false
//                    }
//                    .disabled(roomName.isEmpty || selectedImage == nil)
//                }
//            }
//            .sheet(isPresented: $showImagePicker) {
//                ImagePicker(image: $selectedImage)
//                    .onDisappear {
//                        if selectedImage != nil {
//                            uploadImageToFirebase { imageURL in
//                                guard let imageURL = imageURL else {
//                                    print("Failed to get image URL")
//                                    return
//                                }
//                                
//                                // Now you can proceed to add the category with the imageURL
//                                addCategory(imageURL: imageURL)
//                            }
//                        }
//                    }
//            }
//        }
//    }
//    
//    private func uploadImageToFirebase(completion: @escaping (String?) -> Void) {
//        guard let image = selectedImage else {
//            completion(nil)
//            return
//        }
//        
//        let storage = Storage.storage().reference()
//        let imageRef = storage.child("categories/\(UUID().uuidString).jpg")
//        
//        if let imageData = image.jpegData(compressionQuality: 0.75) {
//            imageRef.putData(imageData, metadata: nil) { _, error in
//                if let error = error {
//                    print("Error uploading image: \(error)")
//                    completion(nil)
//                    return
//                }
//                
//                imageRef.downloadURL { url, error in
//                    if let error = error {
//                        print("Error getting download URL: \(error)")
//                        completion(nil)
//                    } else {
//                        completion(url?.absoluteString)
//                    }
//                }
//            }
//        } else {
//            completion(nil)
//        }
//    }
//
//    private func addCategory(imageURL: String) {
//        guard !roomName.isEmpty else {
//            print("Room name is empty.")
//            return
//        }
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
//            // Fetch new categories
//            HomeViewViewModel().fetchCategories()
//            // Fetch new category names
//            RoomPlanViewViewModel().fetchCategoryNames()
//            
//            isShowingAddRoomView = false
//        }
//    }
//}
//




import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct AddRoomView: View {
    @Binding var isShowingAddRoomView: Bool
    @State private var roomName = ""
    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?
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
                    
                    if let croppedImage = croppedImage {
                        Image(uiImage: croppedImage)
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
                    .disabled(roomName.isEmpty || croppedImage == nil)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .onDisappear {
                        if let selectedImage = selectedImage {
                            // Crop the image to landscape
                            croppedImage = cropImageToLandscape(selectedImage)
                            
                            // Proceed to upload the cropped image
                            if let croppedImage = croppedImage {
                                uploadImageToFirebase(croppedImage: croppedImage) { imageURL in
                                    guard let imageURL = imageURL else {
                                        print("Failed to get image URL")
                                        return
                                    }
                                    addCategory(imageURL: imageURL)
                                }
                            }
                        }
                    }
            }
        }
    }
    
    private func cropImageToLandscape(_ image: UIImage) -> UIImage? {
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


    private func uploadImageToFirebase(croppedImage: UIImage, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage().reference()
        let imageRef = storage.child("categories/\(UUID().uuidString).jpg")
        
        if let imageData = croppedImage.jpegData(compressionQuality: 0.75) {
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
            print("Document added successfully")
            // Fetch new categories
            HomeViewViewModel().fetchCategories()
            // Fetch new category names
            RoomPlanViewViewModel().fetchCategoryNames()
            
            isShowingAddRoomView = false
        }
    }
}
