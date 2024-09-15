import SwiftUI
import PhotosUI

import SwiftUI
import FirebaseStorage

struct RoomDetailsFormView: View {
    @State private var roomName: String = ""
    @State private var roomType: String = ""
    @State private var image: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var isSaving: Bool = false
    @State private var imageUrl: String = ""
    
    var modelUrl: String
    var onSave: (Room) -> Void
    
    var body: some View {
        VStack {
            TextField("Room Name", text: $roomName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Room Type", text: $roomType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Select Image") {
                isImagePickerPresented = true
            }
            .padding()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            
            Button("Save") {
                if let image = image {
                    uploadImage(image) { url in
                        let room = Room(
                            id: UUID().uuidString,
                            roomName: roomName,
                            roomType: roomType,
                            imageUrl: url ?? "",
                            image: image,
                            modelUrl: modelUrl
                        )
                        onSave(room)
                    }
                } else {
                    let room = Room(
                        id: UUID().uuidString,
                        roomName: roomName,
                        roomType: roomType,
                        imageUrl: "",
                        image: UIImage(),
                        modelUrl: modelUrl
                    )
                    onSave(room)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $image)
        }
    }
    
    // Function to upload image to Firebase Storage
    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("roomImages/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error retrieving download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
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
