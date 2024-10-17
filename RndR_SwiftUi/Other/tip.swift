//
//  tip.swift
//  RndR_SwiftUi
//
//  Created by Prabal Kumar on 15/10/24.
//

import Foundation
import TipKit

struct DeleteRoomTip: Tip {
    var title: Text {
        Text("Delete Room")
    }
    
    var message: Text? {
        Text("Tap to delete this room.")
    }
    
    var image: Image? {
        Image(systemName: "trash")
    }
}

struct DetailImage: Tip {
    var title: Text{
        Text("Enlarge Your Profile Image")
    }
    
    var message: Text?{
        Text("Tap and hold on the profile image to enlarge it")
    }
    
    var image: Image?{
        Image(systemName: "photo.stack")
    }
}
