
import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewViewModel()
    @State private var showPickerSheet = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment:.bottom){
                List {
                    if let user = viewModel.user{
                        Section{
                            NavigationLink(destination: UserDetailView()){
                                HStack(spacing:20){
                                    
                                    WebImage(url: URL(string: user.profileImageUrl ?? ""))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .background(.thickMaterial)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                    
                                    VStack(alignment: .leading){
                                        Text(user.name)
                                            .font(.title2)
                                            .fontWeight(.regular)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        
                                        
                                        Text(user.email)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.light)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.6)
                                        
                                    }
                                }
                            }
                        }
                        
                        Section{
                            NavigationLink(destination:AboutUsView()){
                                Label {
                                    Text("About")
                                } icon: {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray)
                                            .frame(width:30,height: 30)
                                        
                                        Image(systemName: "gear")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Contact Support")) {
                            Label {
                                Text("Help")
                            } icon: {
                                Image(systemName: "questionmark.app.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                                    .frame(width:20,height: 22)
                                    .background(Color.white)
                            }
                            
                        }
                        Section {
                            HStack {
                                Spacer()
                                Button(action: {
                                    showLogoutAlert = true
                                }) {
                                    Text("Logout")
                                        .foregroundColor(.red)
                                }
                                .alert("Logout?", isPresented: $showLogoutAlert){
                                    Button("Confirm", role: .destructive) {
                                        viewModel.logOut()
                                    }
                                    Button("Cancel", role: .cancel) { }
                                } message: {
                                    Text("You will be returned to the login screen.")
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    else{
                        Text("Loading profile...")
                    }
                    
                }
            }
            .navigationTitle("Profile")
        }
        
        .onAppear(){
            viewModel.fetchUser()
        }
    }
}

#Preview {
    ProfileView()
}

struct AboutUsView: View {
    var body: some View {
        
        List{
            HStack{
                Text("Version")
                Spacer()
                Text("1.0")
                    .foregroundColor(.secondary)
            }
            
            HStack{
                Text("Website")
                Spacer()
                Text("Rndr@gmail.com")
                    .foregroundColor(.blue)
            }
            
        }
        
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
