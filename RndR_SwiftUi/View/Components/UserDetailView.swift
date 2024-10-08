import SwiftUI

struct UserDetailView: View {
    @StateObject var viewModel = ProfileViewViewModel()
    @State private var showingCloseAccountView = false
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""

    var body: some View {
        List {
            if let user = viewModel.user {
                Section {
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
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCloseAccountView) {
            CloseAccountView(showingCloseAccountView: $showingCloseAccountView)
        }
        .onAppear {
            viewModel.fetchUser()
            // Set initial values for editing when user is fetched
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
