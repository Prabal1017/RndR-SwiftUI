//
//  TLButton.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import SwiftUI

struct TLButton: View {
    
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button{
            action()
        } label: {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 50) // 90% width, fixed height
                .background(background)
                .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    TLButton(title: "button", background: .gray) {
        //        action
    }
}
