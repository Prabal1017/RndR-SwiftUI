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
        NavigationView {
            if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
                TabView {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house") }
                    
                    ScanNewRoomView()
                        .tabItem { Label("Create", systemImage: "plus.app") }
                    
                    ProfileView()
                        .tabItem { Label("Profile", systemImage: "person.circle") }
                }
                .onAppear {
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithTransparentBackground()
                    
                    // Create and set the blur effect for the glass appearance
                    let blurEffect = UIBlurEffect(style: .systemMaterial) // You can change the style to .light, .dark, or .systemChromeMaterial
                    tabBarAppearance.backgroundEffect = blurEffect
                    
                    // Set the background color to semi-transparent (optional)
                    tabBarAppearance.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
                    
                    // Apply the appearance to both standard and scroll edge appearance
                    UITabBar.appearance().standardAppearance = tabBarAppearance
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                }
            } else {
                LandingView()
            }
        }
    }
}

#Preview {
    MainView()
}
