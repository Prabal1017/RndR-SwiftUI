//
//  ContentView.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var viewModel = MainViewViewModel()
    
    var body: some View {
        NavigationView{
            if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
                TabView(){
                    HomeView().tabItem { Label("Home", systemImage: "house")}
                    
                    CreateView().tabItem { Label("Create", systemImage: "plus.app")}
                    
                    ProfileView().tabItem { Label("Profile", systemImage: "person.circle")}
                }
            }
            else{
                LandingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainView()
}
