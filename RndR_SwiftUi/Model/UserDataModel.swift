//
//  UserDataModel.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import Foundation
import FirebaseCore

struct User: Codable{
    let id: String
    let name: String
    let email: String
    let joined: Timestamp
}
