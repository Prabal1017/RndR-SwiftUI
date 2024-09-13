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
                    
                    ProfileView().tabItem { Label("Home", systemImage: "person.circle")}
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
