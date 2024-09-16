//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//
//class RegisterViewViewModel: ObservableObject {
//    @Published var name = ""
//    @Published var email = ""
//    @Published var password = ""
//    
//    init() {}
//    
//    func register() {
//        guard validate() else {
//            return
//        }
//        
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
//            guard let userId = result?.user.uid else {
//                return
//            }
//            
//            self?.insertUserRecord(id: userId)
//        }
//    }
//    
//    private func insertUserRecord(id: String) {
//        let newUser = User(id: id, name: name, email: email, joined: Timestamp(date: Date())) // Use Firebase Timestamp to store the exact time
//        
//        let db = Firestore.firestore()
//        
//        db.collection("users")
//            .document(id)
//            .setData(newUser.asDictionary()) { error in
//                if let error = error {
//                    print("Error saving user data: \(error)")
//                } else {
//                    print("User data successfully saved")
//                }
//            }
//    }
//    
//    private func validate() -> Bool {
//        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
//              !email.trimmingCharacters(in: .whitespaces).isEmpty,
//              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
//            return false
//        }
//        
//        guard email.contains("@") && email.contains(".") else {
//            return false
//        }
//        
//        guard password.count >= 6 else {
//            return false
//        }
//        return true
//    }
//}



import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    init() {}
    
    func register() {
        guard validate() else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else {
                return
            }
            
            self?.insertUserRecord(id: userId)
        }
    }
    
    private func insertUserRecord(id: String) {
        let newUser = User(id: id, name: name, email: email, joined: Timestamp(date: Date())) // Use Firebase Timestamp to store the exact time
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary()) { error in
                if let error = error {
                    print("Error saving user data: \(error)")
                } else {
                    print("User data successfully saved")
                }
            }
    }
    
    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            return false
        }
        
        return isValidPassword(password)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{7,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
