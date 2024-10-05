
import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewViewModel()
    @State private var showPickerSheet = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment:.bottom){
                List {
                    if let user = viewModel.user{
                        Section{
                            NavigationLink(destination: UserDetailView()){
                                HStack(spacing:20){
                                    ZStack {
                                        // Circle shape background
                                        Circle()
                                        
                                            .frame(width: 70, height: 70)
                                        
                                        // Image inside the circle
                                        Image("Image")
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                            .frame(width: 70, height: 70)
                                            .aspectRatio(contentMode: .fill)
                                    }
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
            
//                            HStack {
//                                Text("Member Since")
//                                Spacer()
//                                // Convert Timestamp to Date and format it
//                                Text("\(user.joined.dateValue().formatted(date: .abbreviated, time: .shortened))")
//                                    .foregroundColor(.secondary)
//                            }
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
                                    viewModel.logOut() // Call the log out action
                                }) {
                                    Text("Logout")
                                        .foregroundColor(.red)
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
