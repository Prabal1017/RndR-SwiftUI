//
//  ProfileViewViewModel.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ProfileViewViewModel: ObservableObject{
    init() {}
    
    @Published var user: User? = nil
    
    //MARK: - fetch current user
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    return
                }

                guard let data = snapshot?.data() else {
                    print("No data found.")
                    return
                }

                print("Fetched data: \(data)")

                if let timestamp = data["joined"] as? Timestamp {
                    let joinedDate = timestamp.dateValue()

                    DispatchQueue.main.async {
                        self?.user = User(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            joined: timestamp // Store the Timestamp directly
                        )
                    }
                } else {
                    print("Timestamp not found in data.")
                    DispatchQueue.main.async {
                        self?.user = User(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            joined: Timestamp(date: Date()) // Fallback if no Timestamp is present
                        )
                    }
                }
            }
    }

    //MARK: - logout function
    func logOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
    }
}

