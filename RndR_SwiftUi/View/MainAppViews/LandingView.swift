//
//  LandingView.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 12/09/24.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        ZStack{
            Image("landingPage")
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                VStack (spacing: 0){
                    Text("Welcome")
                        .font(.system(size: 50))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.gray)
                    Text("to")
                        .font(.system(size: 50))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.gray)
                    Text("RndR")
                        .font(.system(size: 50))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
                        .bold()
                }
                .padding([.leading, .top])
                
                Spacer()
                
                NavigationLink(destination: LoginView()){
                    Text("Login")
                        .padding(.horizontal, 130)
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .font(.title3)
                }
                
                HStack{
                    Text("Don't have an account?")
                        .font(.footnote)
                        .foregroundColor(.white)
                    NavigationLink("Signup", destination: RegisterView())
                        .font(.footnote)
                }
                .padding(5)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    LandingView()
}
