//
//  ProfileView.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewViewModel()
    @State private var showPickerSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if let user = viewModel.user{
                        Section(header: Text("Admin Details")) {
                            HStack {
                                Text("Name : ")
                                    .bold()
                                Spacer()
                                Text(user.name)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Email : ")
                                    .bold()
                                Spacer()
                                Text(user.email)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Member Since : ")
                                    .bold()
                                Spacer()
                                Text("\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("App Details")) {
                            HStack {
                                Text("Version")
                                    .bold()
                                Spacer()
                                Text("v1")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("Contact Support")) {
                            HStack {
                                Text("Email : ")
                                    .bold()
                                Spacer()
                                Text("RndR@gmail.com")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    else{
                        Text("Loading profile....")
                    }
                        
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for logout
                        viewModel.logOut()
                    }) {
                        Text("Log Out")
                    }
                    .tint(.red)
                }
            }
            .onAppear(){
                viewModel.fetchUser()
            }
        }
    }
}

#Preview {
    ProfileView()
}
