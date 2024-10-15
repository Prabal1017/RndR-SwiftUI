//
//  ModelViewModel.swift
//  RndR_SwiftUi
//
//  Created by Prabal Kumar on 12/10/24.
//

//import Foundation
//import FirebaseFirestore
//
//class FurnitureModelViewModel: ObservableObject {
//    @Published var models: [FurnitureModel] = []
//    
//    private let db = Firestore.firestore()
//    
//    func fetchData() {
//        db.collection("FurnitureModels").addSnapshotListener { (querySnapshot, error ) in
//            guard let documents = querySnapshot?.documents else {
//                print("Firestore: No documents")
//                return
//            }
//            
//            self.models = documents.map { (queryDocumentSnapshot) -> FurnitureModel in
//                let data = queryDocumentSnapshot.data()
//                let name = data["name"] as? String ?? ""
//                let categoryText = data["category"] as? String ?? ""
//                let category = ModelCategory(rawValue: categoryText) ?? .decor
//                let scaleCompensation = data["scaleCompensation"] as? Double ?? 1.0
//                
//                return FurnitureModel(name: name, category: category, scaleCompensation: Float(scaleCompensation))
//            }
//        }
//    }
//    
//    
//    func clearModelEntitiesFromMemory() {
//        for model in models{
//            model.modelEntity = nil
//        }
//    }
//}


import Firebase
import FirebaseFirestore

class FurnitureModelViewModel: ObservableObject {
    @Published var furnitureModels: [FurnitureModel] = [] // Array to hold furniture models
    
    func fetchFurnitureModels() {
        let db = Firestore.firestore()
        
        // Fetching from the "FurnituresUrl" collection
        db.collection("FurnituresUrl").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching furniture models: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            self.furnitureModels = documents.compactMap { document -> FurnitureModel? in
                // Decoding each document into a FurnitureModel
                do {
                    let data = try document.data(as: FurnitureModel.self)
                    return data
                } catch {
                    print("Error decoding FurnitureModel: \(error)")
                    return nil
                }
            }
        }
    }
}
