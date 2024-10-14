//
//  DeletionView.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 14/10/24.
//

import SwiftUI

struct DeletionView: View {
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    
    var body: some View{
        HStack{
            Spacer()
            
            Button{
                print("Cancel deletion button pressed.")
                self.modelDeletionManager.entitySelectedForDeletion = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            
            Spacer()
            
            Button{
                print("Confirm deletion button pressed.")
                guard let anchor = self.modelDeletionManager.entitySelectedForDeletion?.anchor else { return }
                
                let anchoringIdentifier = anchor.anchorIdentifier
                if let index = self.sceneManager.anchorEntities.firstIndex(where: { $0.anchorIdentifier == anchoringIdentifier}){
                    print("Deleting anchorEntity with id: \(String(describing: anchoringIdentifier))")
                    self.sceneManager.anchorEntities.remove(at: index)
                }
                
                anchor.removeFromParent()
                self.modelDeletionManager.entitySelectedForDeletion = nil
            } label: {
                Image(systemName: "trash.circle.fill")
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct DeletionButton: View {
    
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        Button{
            self.action()
        } label: {
            Image(systemName: systemIconName)
                .font(.system(size: 50, weight: .light, design: .default))
                .foregroundColor(.white)
        }
        .frame(width: 75,height: 75)
    }
}
