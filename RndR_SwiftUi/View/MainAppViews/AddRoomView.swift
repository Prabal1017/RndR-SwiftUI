//
//  AddRoomView.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 16/09/24.
//

import SwiftUI

struct AddRoomView: View {
    @Binding var isShowingAddRoomView: Bool
    @State private var roomName = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter room name", text: $roomName)
            }
            .navigationTitle("New Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isShowingAddRoomView = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !roomName.isEmpty {
                            // Add room logic here
                            isShowingAddRoomView = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddRoomView(isShowingAddRoomView: .constant(true))
}
