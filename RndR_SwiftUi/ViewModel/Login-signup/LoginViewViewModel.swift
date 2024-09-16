//
//  LoginViewViewModel.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore

class LoginViewViewModel: ObservableObject {
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    init(){}
    
    func login() {
        
        guard validate() else{
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password)
    }
    
    private func validate() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else{
            errorMessage = "Please fill in all the fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else{
            errorMessage = "Please enter valid email."
            return false
        }
        
        return true
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { [self] user, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            guard let user = user?.user else {
                return
            }
            
            let idToken = user.idToken!.tokenString
            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { [self] res, error in
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                
                guard let firebaseUser = res?.user else { return }
                
                // Store user information in Firestore after Google sign-in
                storeUserInfo(firebaseUser: firebaseUser)
            }
        }
    }

    // Function to store user info in Firestore if the user is new
    func storeUserInfo(firebaseUser: FirebaseAuth.User) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(firebaseUser.uid)
        
        // Check if the user already exists
        docRef.getDocument { snapshot, error in
            if let document = snapshot, document.exists {
                // User already exists, no need to store again
                print("User already exists in Firestore")
            } else {
                // New user, store their information with the exact sign-in time
                let userData: [String: Any] = [
                    "id": firebaseUser.uid,
                    "name": firebaseUser.displayName ?? "",
                    "email": firebaseUser.email ?? "",
                    "joined": Timestamp(date: Date())  // Using Firebase Timestamp for the exact sign-in time
                ]
                
                // Store the user data in Firestore
                docRef.setData(userData) { error in
                    if let error = error {
                        print("Error saving user data: \(error)")
                    } else {
                        print("User data successfully saved to Firestore")
                    }
                }
            }
        }
    }
    
    // Helper function to get the root view controller
    func getRootViewController() -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
}


