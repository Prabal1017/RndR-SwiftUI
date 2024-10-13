import SwiftUI
import QuickLook
import UIKit

struct NativeQuickLookView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let url: URL
        
        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return url as QLPreviewItem
        }

        func previewControllerWillDismiss(_ controller: QLPreviewController) {
            print("QuickLook view dismissed.")
        }
    }
}

import SwiftUI
import QuickLook

//struct FileDetailView: View {
//    let fileName: String
//    let modelURL: URL
//    @State private var useARMode = true
//    @State private var isLoading = true // Loading state
//    @State private var loadedURL: URL? // URL to hold the loaded model
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Loading model...") // Display a loading indicator
//                    .onAppear {
//                        loadModel()
//                    }
//            } else if let loadedURL = loadedURL {
//                NativeQuickLookView(url: loadedURL)
//                    .if(useARMode) { view in
//                        view.edgesIgnoringSafeArea(.all)
//                    }
//                    .onAppear { print("Opening USDZ file: \(loadedURL) in \(useARMode ? "AR" : "Object") mode") }
//            } else {
//                Text("Unable to load file")
//                    .foregroundColor(.red)
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle(fileName)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(useARMode ? "Object Mode" : "AR Mode") {
//                    useARMode.toggle()
//                }
//            }
//        }
//    }
//
//    private func loadModel() {
//        DispatchQueue.global(qos: .background).async {
//            // Simulate network loading time
//            let urlSession = URLSession.shared
//            
//            // Fetch the USDZ file
//            let task = urlSession.dataTask(with: modelURL) { data, response, error in
//                if let error = error {
//                    print("Error loading model: \(error)")
//                    DispatchQueue.main.async {
//                        isLoading = false
//                        loadedURL = nil // Invalidate loaded URL
//                    }
//                    return
//                }
//                
//                if let data = data {
//                    // Create a temporary file URL to save the model
//                    let temporaryDirectory = FileManager.default.temporaryDirectory
//                    let temporaryFileURL = temporaryDirectory.appendingPathComponent("model.usdz")
//                    
//                    do {
//                        try data.write(to: temporaryFileURL) // Write data to temporary file
//                        DispatchQueue.main.async {
//                            loadedURL = temporaryFileURL // Update loaded URL on the main thread
//                            isLoading = false // Stop loading
//                        }
//                    } catch {
//                        print("Error saving model: \(error)")
//                        DispatchQueue.main.async {
//                            isLoading = false
//                            loadedURL = nil // Invalidate loaded URL
//                        }
//                    }
//                }
//            }
//            task.resume() // Start the data task
//        }
//    }
//}




struct FileDetailView: View {
    let fileName: String
    let modelURL: URL
    @State private var useARMode = true
    @State private var isLoading = true // Loading state
    @State private var loadedURL: URL? // URL to hold the loaded model

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading model...") // Display a loading indicator
                    .onAppear {
                        loadModel()
                    }
            } else if let loadedURL = loadedURL {
                if useARMode {
                    // Display in AR mode using Model3DView
                    Model3DView(modelUrl: loadedURL, viewModel: CustomModel3DViewModel(originalModelUrl: modelURL)) // Replace with your Model3DView
                        .edgesIgnoringSafeArea(.all)
                        .onAppear { print("Opening USDZ file: \(loadedURL) in AR mode") }
                } else {
                    // Display using Quick Look
                    NativeQuickLookView(url: loadedURL)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear { print("Opening USDZ file: \(loadedURL) in Object mode") }
                }
            } else {
                Text("Unable to load file")
                    .foregroundColor(.red)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(fileName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(useARMode ? "Object Mode" : "AR Mode") {
                    useARMode.toggle()
                }
            }
        }
    }

    private func loadModel() {
        DispatchQueue.global(qos: .background).async {
            let urlSession = URLSession.shared
            
            // Fetch the USDZ file
            let task = urlSession.dataTask(with: modelURL) { data, response, error in
                if let error = error {
                    print("Error loading model: \(error)")
                    DispatchQueue.main.async {
                        isLoading = false
                        loadedURL = nil // Invalidate loaded URL
                    }
                    return
                }
                
                if let data = data {
                    // Create a temporary file URL to save the model
                    let temporaryDirectory = FileManager.default.temporaryDirectory
                    let temporaryFileURL = temporaryDirectory.appendingPathComponent("model.usdz")
                    
                    do {
                        try data.write(to: temporaryFileURL) // Write data to temporary file
                        DispatchQueue.main.async {
                            loadedURL = temporaryFileURL // Update loaded URL on the main thread
                            isLoading = false // Stop loading
                        }
                    } catch {
                        print("Error saving model: \(error)")
                        DispatchQueue.main.async {
                            isLoading = false
                            loadedURL = nil // Invalidate loaded URL
                        }
                    }
                }
            }
            task.resume() // Start the data task
        }
    }
}



extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
