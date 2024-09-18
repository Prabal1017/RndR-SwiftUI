
import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewViewModel()
    @State private var showPickerSheet = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment:.bottom){
                List {
                    if let user = viewModel.user{
                        Section(header: Text("Admin Details")) {
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
                        
                        Section(header: Text("App Details")) {
                            HStack {
                                Text("Version")
                                Spacer()
                                Text("V1")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("Contact Support")) {
                            HStack {
                                Text("Email")
                                Spacer()
                                Text("RndR@gmail.com")
                                    .foregroundColor(.secondary)
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
