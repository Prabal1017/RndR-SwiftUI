//import SwiftUI
//import PhotosUI
//
//struct RoomDetailsFormView: View {
//    @State private var roomName: String = ""
//    @State private var roomType: String = "" // Updated to handle dynamic categories
//    @State private var image: UIImage? = nil
//    @State private var isImagePickerPresented: Bool = false
//    @State private var isSaving: Bool = false
//    @State private var imageUrl: String = ""
//    
//    @StateObject private var viewModel = RoomPlanViewViewModel()
//    
//    var modelUrl: String
//    var onSave: (Room) -> Void
//    
//    var body: some View {
//        VStack {
//            TextField("Room Name", text: $roomName)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            // Dropdown menu for selecting room type
//            if viewModel.categoryNames.isEmpty {
//                ProgressView("Loading categories...")
//                    .padding()
//            } else {
//                Picker("Room Type", selection: $roomType) {
//                    ForEach(viewModel.categoryNames, id: \.self) { type in
//                        Text(type)
//                    }
//                }
//                .pickerStyle(MenuPickerStyle()) // You can also use other picker styles
//                .padding()
//            }
//            
//            Button("Select Image") {
//                isImagePickerPresented = true
//            }
//            .padding()
//            
//            if let image = image {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 200)
//                    .padding()
//            }
//            
//            Button("Save") {
//                if let image = image {
//                    viewModel.uploadImage(image, roomType: roomType) { url in
//                        let room = Room(
//                            id: UUID().uuidString,
//                            roomName: roomName,
//                            roomType: roomType,
//                            imageUrl: url ?? "",
//                            image: image,
//                            modelUrl: modelUrl
//                        )
//                        viewModel.saveRoomData(room)
//                        onSave(room)
//                    }
//                } else {
//                    let room = Room(
//                        id: UUID().uuidString,
//                        roomName: roomName,
//                        roomType: roomType,
//                        imageUrl: "",
//                        image: UIImage(),
//                        modelUrl: modelUrl
//                    )
//                    viewModel.saveRoomData(room)
//                    onSave(room)
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .padding()
//        }
//        .onAppear {
//            viewModel.fetchCategoryNames()
//        }
//        .sheet(isPresented: $isImagePickerPresented) {
//            ImagePicker(image: $image)
//        }
//    }
//}
//
//
//
//
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//    
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        var parent: ImagePicker
//        
//        init(parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            // Process the selected image
//            if let provider = results.first?.itemProvider {
//                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
//                    provider.loadObject(ofClass: UIImage.self) { image, error in
//                        DispatchQueue.main.async {
//                            if let uiImage = image as? UIImage {
//                                self.parent.image = uiImage
//                            } else {
//                                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
//                            }
//                        }
//                    }
//                }
//            }
//            picker.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//    
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var config = PHPickerConfiguration()
//        config.selectionLimit = 1
//        config.filter = .images
//        
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//}




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
    
    var body: some View {
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
                .pickerStyle(MenuPickerStyle()) // You can also use other picker styles

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
            
            Button("Save") {
                let timestamp = Timestamp() // Current timestamp
                
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
                        viewModel.saveRoomData(room)
                        onSave(room)
                    }
                } else {
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
                    onSave(room)
                }
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
