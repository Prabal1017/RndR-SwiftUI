//
//  RegisterView.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject var viewModel = RegisterViewViewModel()
    @StateObject var loginViewModel = LoginViewViewModel();
    
    var body: some View {
        VStack{
            VStack{
                Image("register")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                    .shadow(radius: 5)
            }
            
            VStack{
                TextField("Username", text: $viewModel.name)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                TextField("Email ID", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                SecureField("Password", text: $viewModel.password)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                TLButton(title: "Register", background: .green){
                    viewModel.register()
                }
                
                HStack{
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray) // Change color if needed
                    
                    Text("or")
                        .padding(.horizontal, 10)
                        .foregroundColor(.gray)
                    
                    // Second horizontal line
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                }
                .padding(.bottom)
                
                Button(action: {
                    loginViewModel.signInWithGoogle()
                }) {
                    HStack {
                        Spacer()
                        
                        Image("googleLogo.svg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        
                        Text("Sign in with Google")
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(15)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 50) // 90% width, fixed height
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkTeal, Color.darkTeal, Color.black]), startPoint: .top, endPoint: .bottom))
    }
}

#Preview {
    RegisterView()
}
