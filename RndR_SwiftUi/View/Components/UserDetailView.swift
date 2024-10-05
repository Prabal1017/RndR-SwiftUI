//
//  UserDetailView.swift
//  RndR_SwiftUi
//
//  Created by Prabal Kumar on 03/10/24.
//

import SwiftUI

struct UserDetailView: View {
    
    @StateObject var viewModel = ProfileViewViewModel()
    @State private var showingCloseAccountView = false
    @State private var isEditing = false
    
    var body: some View {
            List{
                if let user = viewModel.user{
                    Section{
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(user.name)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Member Since")
                            Spacer()
                            // Convert Timestamp to Date and format it
                            Text("\(user.joined.dateValue().formatted(date: .abbreviated, time: .shortened))")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section{
                        Button{
                            showingCloseAccountView = true
                        } label:{
                            HStack {
                                Text("Close Account")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                else{
                    Text("Loading...")
                }
            }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button{
                    isEditing.toggle()
                } label: {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
        }
        .sheet(isPresented: $showingCloseAccountView) {
            CloseAccountView(showingCloseAccountView: $showingCloseAccountView) // Present the CloseAccountView as a modal
        }
        
        .onAppear(){
            viewModel.fetchUser()
        }
    }
}

#Preview {
    UserDetailView()
}
