//
//  LoginView.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewViewModel()
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack{
            VStack {
                Image("login")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                    .shadow(radius: 5)
            }
            
            VStack(spacing: 10){
                if !viewModel.errorMessage.isEmpty{
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                TextField("Email ID", text: $viewModel.email)
                    .foregroundColor(.white)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                SecureField("Password", text: $viewModel.password)
                    .foregroundColor(.white)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                Spacer()
                
                TLButton(title: "Login", background: .blue){
                    viewModel.login()
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
                    viewModel.signInWithGoogle()
                }) {
                    HStack {
                        Spacer()
                        
                        Image("googleLogo.svg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        
                        Text("Sign in with Google")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(15)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 50) // 90% width, fixed height
                
            }
            .padding(.horizontal, 20)
            
            HStack{
                Text("New around here?")
                    .font(.footnote)
                    .foregroundColor(.white)
                NavigationLink("Create an account", destination: RegisterView())
                    .font(.footnote)
                
            }
            .padding()
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkTeal, Color.darkTeal, Color.black]), startPoint: .top, endPoint: .bottom))
    }
}


#Preview {
    LoginView()
}
