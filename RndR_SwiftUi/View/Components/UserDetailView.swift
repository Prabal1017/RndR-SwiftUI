//import SwiftUI
//
//struct UserDetailView: View {
//    @StateObject var viewModel = ProfileViewViewModel()
//    @State private var showingCloseAccountView = false
//    @State private var isEditing = false
//    @State private var editedName: String = ""
//    @State private var editedEmail: String = ""
//
//    var body: some View {
//        List {
//            if let user = viewModel.user {
//                Section {
//                    // Name Field
//                    HStack {
//                        Text("Name")
//                        Spacer()
//                        if isEditing {
//                            TextField("Name", text: $editedName)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                        } else {
//                            Text(user.name)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//
//                    // Email Field
//                    HStack {
//                        Text("Email")
//                        Spacer()
//                        if isEditing {
//                            TextField("Email", text: $editedEmail)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                        } else {
//                            Text(user.email)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//
//                    // Member Since
//                    HStack {
//                        Text("Member Since")
//                        Spacer()
//                        Text("\(user.joined.dateValue().formatted(date: .abbreviated, time: .shortened))")
//                            .foregroundColor(.secondary)
//                    }
//                }
//
//                Section {
//                    Button {
//                        showingCloseAccountView = true
//                    } label: {
//                        HStack {
//                            Text("Close Account")
//                                .foregroundColor(.primary)
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//            } else {
//                Text("Loading...")
//            }
//        }
//        .navigationTitle("Account")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                if let user = viewModel.user { // Ensure user is accessible here
//                    Button {
//                        if isEditing {
//                            // Save changes to Firebase
//                            viewModel.updateUserDetails(name: editedName, email: editedEmail) { success in
//                                if success {
//                                    print("User details updated successfully.")
//                                } else {
//                                    print("Failed to update user details.")
//                                }
//                            }
//                        } else {
//                            // Pre-fill the fields with current user data for editing
//                            editedName = user.name
//                            editedEmail = user.email
//                        }
//                        isEditing.toggle()
//                    } label: {
//                        Text(isEditing ? "Done" : "Edit")
//                    }
//                }
//            }
//        }
//        .sheet(isPresented: $showingCloseAccountView) {
//            CloseAccountView(showingCloseAccountView: $showingCloseAccountView)
//        }
//        .onAppear {
//            viewModel.fetchUser()
//            // Set initial values for editing when user is fetched
//            if let user = viewModel.user {
//                editedName = user.name
//                editedEmail = user.email
//            }
//        }
//    }
//}
//
//#Preview {
//    UserDetailView()
//}


import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import FirebaseAuth
import PhotosUI

struct UserDetailView: View {
    @StateObject var viewModel = ProfileViewViewModel()
    @State private var showingCloseAccountView = false
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingImagePreview = false
    
    var body: some View {
        ZStack{
            NavigationView{
                List {
                    if let user = viewModel.user {
                        Section {
                            // Profile Image
                            HStack {
                                Spacer()
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .background(.thickMaterial)
                                        .clipShape(Circle())
                                    //                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                        .shadow(radius: 5)
                                        .onTapGesture {
                                            showingImagePicker = true // Open image picker when tapped
                                        }
                                } else {
                                    WebImage(url: URL(string: user.profileImageUrl ?? ""))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .background(.thickMaterial)
                                        .clipShape(Circle())
                                    //                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                        .shadow(radius: 5)
                                        .onTapGesture {
                                            showingImagePicker = true // Open image picker when tapped
                                        }
                                        .onLongPressGesture {
                                            showingImagePreview = true
                                        }
                                    
                                }
                                Spacer()
                            }
                            .padding(.vertical)
                            
                            // Name Field
                            HStack {
                                Text("Name")
                                Spacer()
                                if isEditing {
                                    TextField("Name", text: $editedName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                } else {
                                    Text(user.name)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Email Field
                            HStack {
                                Text("Email")
                                Spacer()
                                if isEditing {
                                    TextField("Email", text: $editedEmail)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                } else {
                                    Text(user.email)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Member Since
                            HStack {
                                Text("Member Since")
                                Spacer()
                                Text("\(user.joined.dateValue().formatted(date: .abbreviated, time: .shortened))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section {
                            Button {
                                showingCloseAccountView = true
                            } label: {
                                HStack {
                                    Text("Close Account")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    } else {
                        Text("Loading...")
                    }
                }
            }
            .blur(radius: showingImagePreview ? 20 : 0)
            .disabled(showingImagePreview)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let user = viewModel.user { // Ensure user is accessible here
                        Button {
                            if isEditing {
                                // Save changes to Firebase
                                viewModel.updateUserDetails(name: editedName, email: editedEmail) { success in
                                    if success {
                                        print("User details updated successfully.")
                                    } else {
                                        print("Failed to update user details.")
                                    }
                                }
                            } else {
                                // Pre-fill the fields with current user data for editing
                                editedName = user.name
                                editedEmail = user.email
                            }
                            isEditing.toggle()
                        } label: {
                            if !showingImagePreview {
                                Text(isEditing ? "Done" : "Edit")
                            }
                            
                        }
                    }
                }
            }
            if showingImagePreview{
                UserImagePreview(showingImagePreview: $showingImagePreview,profileImageUrl: viewModel.user?.profileImageUrl ?? "")
            }

            
        }
        .refreshable {
            viewModel.fetchUser()
        }
        .sheet(isPresented: $showingCloseAccountView) {
            CloseAccountView(showingCloseAccountView: $showingCloseAccountView)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                // Upload the selected image to Firebase
                viewModel.uploadProfileImage(image: image) { success in
                    if success {
                        print("Image uploaded successfully.")
                    } else {
                        print("Failed to upload image.")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchUser()
            if let user = viewModel.user {
                editedName = user.name
                editedEmail = user.email
            }
        }
    }
}

#Preview {
    UserDetailView()
}
