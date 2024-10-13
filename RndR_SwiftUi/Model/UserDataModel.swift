//
//  UserDataModel.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import Foundation
import FirebaseCore

//struct User: Codable{
//    let id: String
//    var name: String
//    var email: String
//    let joined: Timestamp
//}


struct User: Codable {
    let id: String
    var name: String
    var email: String
    let joined: Timestamp
    var profileImageUrl: String? // Optional profile image URL
}
