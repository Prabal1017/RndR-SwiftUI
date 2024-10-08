import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

struct AddRoomView: View {
    @Binding var isShowingAddRoomView: Bool
    @State private var roomName = ""
    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imageURL: String?
    @ObservedObject var viewModel: RoomPlanViewViewModel
    @StateObject var categoryViewModel = CategoryViewViewModel()

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
                        if let croppedImage = croppedImage {
                            categoryViewModel.uploadImageToFirebase(croppedImage: croppedImage) { imageURL in
                                guard let imageURL = imageURL else {
                                    print("Failed to get image URL")
                                    return
                                }
                                
                                // Add the room and dismiss view when successful
                                categoryViewModel.addCategory(imageURL: imageURL, roomName: roomName)
                                isShowingAddRoomView = false
                            }
                        }
                    }
                    .disabled(roomName.isEmpty || croppedImage == nil)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .onDisappear {
                        if let selectedImage = selectedImage {
                            // Crop the image to landscape
                            croppedImage = categoryViewModel.cropImageToLandscape(selectedImage)
                        }
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
