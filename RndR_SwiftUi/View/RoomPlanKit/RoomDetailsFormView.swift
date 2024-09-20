import SwiftUI
import PhotosUI
import FirebaseFirestore

struct RoomDetailsFormView: View {
    @State private var roomName: String = ""
    @State private var roomType: String = "" // Updated to handle dynamic categories
    @State private var image: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var isSaving: Bool = false
    @State private var imageUrl: String = ""
    
    @StateObject private var viewModel = RoomPlanViewViewModel()
    
    var modelUrl: String
    var onSave: (Room) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                TextField("Room Name", text: $roomName)

                // Dropdown menu for selecting room type
                if viewModel.categoryNames.isEmpty {
                    ProgressView("Loading categories...")
                } else {
                    Picker("Room Type", selection: $roomType) {
                        ForEach(viewModel.categoryNames, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Button("Select Image") {
                    isImagePickerPresented = true
                }
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
            .navigationTitle("Room Details")
            .navigationBarTitleDisplayMode(.inline) // Makes the title inline
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Call the delete function from FirebaseStorageManager to delete the 3D model
                        print("Cancel button pressed")
                        if let modelURL = URL(string: modelUrl) {
                            RoomController.instance.deleteRoomModel(from: modelURL) { success in
                                if success {
                                    print("Model deleted successfully")
                                } else {
                                    print("Failed to delete the model")
                                }
                            }
                        }
                        // Dismiss the view
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard !isSaving else { return } // Prevent multiple save attempts
                        isSaving = true
                        
                        let timestamp = Timestamp() // Current timestamp
                        
                        // Check if an image exists
                        if let image = image {
                            viewModel.uploadImage(image, roomType: roomType) { url in
                                let room = Room(
                                    id: UUID().uuidString,
                                    roomName: roomName,
                                    roomType: roomType,
                                    imageUrl: url ?? "",
                                    image: image,
                                    modelUrl: modelUrl,
                                    timestamp: timestamp // Pass the current timestamp
                                )
                                
                                // Save room data only after the image upload completes
                                viewModel.saveRoomData(room)
                                print("if condition is called")
                                onSave(room)
                                
                                // Dismiss the view after saving
                                presentationMode.wrappedValue.dismiss()
                                isSaving = false // Reset the flag
                            }
                        } else {
                            // No image exists, proceed with saving
                            let room = Room(
                                id: UUID().uuidString,
                                roomName: roomName,
                                roomType: roomType,
                                imageUrl: "",
                                image: UIImage(),
                                modelUrl: modelUrl,
                                timestamp: timestamp // Pass the current timestamp
                            )
                            
                            viewModel.saveRoomData(room)
                            print("else condition is called")
                            onSave(room)
                            
                            // Dismiss the view after saving
                            presentationMode.wrappedValue.dismiss()
                            isSaving = false // Reset the flag
                        }
                    }
                    .disabled(roomName.isEmpty || roomType.isEmpty || modelUrl.isEmpty)
                }

            }
            .onAppear {
                viewModel.fetchCategoryNames()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $image)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Process the selected image
            if let provider = results.first?.itemProvider {
                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadObject(ofClass: UIImage.self) { image, error in
                        DispatchQueue.main.async {
                            if let uiImage = image as? UIImage {
                                self.parent.image = uiImage
                            } else {
                                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                            }
                        }
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
