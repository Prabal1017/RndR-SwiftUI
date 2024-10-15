//
//  Model.swift
//  ArView
//
//  Created by Prabal Kumar on 08/10/24.
//

//import SwiftUI
//import RealityKit
//import Combine
//
//enum ModelCategory: String, CaseIterable {
//    case table
//    case chair
//    case decor
//    case bed
//    
//    var label: String {
//        get{
//            switch self {
//            case .table: return "Table"
//            case .chair: return "Chair"
//            case .decor: return "Decor"
//            case .bed: return "Bed"
//            }
//        }
//    }
//}
//
//class FurnitureModel: ObservableObject, Identifiable{
//    var id: String = UUID().uuidString
//    var name: String
//    var category: ModelCategory
//    @Published var thumbnail: UIImage
//    var modelEntity: ModelEntity?
//    var scaleCompensation: Float
//    
//    private var cancellable: AnyCancellable?
//    
//    init(name: String, category: ModelCategory,scaleCompensation: Float = 1.0) {
//        self.name = name
//        self.category = category
//        self.thumbnail = UIImage(systemName: "photo")!
//        self.scaleCompensation = scaleCompensation
//        
//        FirebaseStorageHelper.asyncDownloadToFileSystem(relativePath: "thumbnails/\(self.name).png"){ localUrl in
//            do {
//                let imageData = try Data(contentsOf: localUrl)
//                self.thumbnail = UIImage(data: imageData) ?? self.thumbnail
//            } catch {
//                print("Error loading image: \(error.localizedDescription)")
//            }
//        }
//    }
//    func asyncLoadModeEntity(handler: @escaping (_ completed: Bool, _ error: Error?) -> Void) {
//        
//        FirebaseStorageHelper.asyncDownloadToFileSystem(relativePath: "FurnitureModels/\(self.name).usdz"){ localUrl in
//            
//            self.cancellable = ModelEntity.loadModelAsync(contentsOf: localUrl)
//                .sink(receiveCompletion: { loadCompletion in
//                    
//                    switch loadCompletion {
//                    case .failure(let error): print("Unable to laod modelEntity for \(self.name). Error: \(error.localizedDescription)")
//                        handler(false, error)
//                    case .finished:
//                        break
//                    }
//                    
//                }, receiveValue: { modelEntity in
//                    
//                    self.modelEntity = modelEntity
//                    self.modelEntity?.scale *= self.scaleCompensation
//                    
//                    handler(true, nil)
//                    
//                    print("modelEntity for \(self.name) has been loaded")
//                })
//            
//            
//        }
//        
//        
//    }
//}
//



import Foundation

struct FurnitureModel: Identifiable, Codable, Equatable {
    let id: String // Unique identifier for the furniture model
    let name: String // Name of the furniture
    let furnitureUrl: String // URL to the furniture model file (e.g., .usdz)
    let image: String // URL to the image of the furniture for display
    let type: String // Type of the furniture (e.g., chair, table, etc.)
    
    // Optional computed property to get the URL from the image string
    var displayImage: URL? {
        return URL(string: image)
    }
}

