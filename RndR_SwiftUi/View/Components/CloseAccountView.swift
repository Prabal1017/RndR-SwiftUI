import SwiftUI
import Firebase

struct CloseAccountView: View {
    @State private var password: String = ""
    @State private var showPasswordAlert: Bool = false
    @State private var showAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @Binding var showingCloseAccountView: Bool
    @StateObject var viewModel = ProfileViewViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Warning"),
                        footer: Text("Closing your account is irreversible and it cannot be undone.")
                    .foregroundColor(.primary)
                    .textCase(nil)) {
                        // Empty section
                    }
                
                Section(header: Text("Deleting your account will logout from all your devices and remove all your 3D scanned models and you won't be able to access them.")
                    .foregroundColor(.primary)
                    .textCase(nil)) {
                        // Empty section
                    }
                
                Section {
                    HStack {
                        Spacer()
                        Button {
                            // Show password input alert
                            showPasswordAlert = true
                        } label: {
                            Text("Close account")
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                }
                // Alert for entering password
                .alert("Enter your password to confirm", isPresented: $showPasswordAlert) {
                    SecureField("Password", text: $password)
                        .textContentType(.password) // For password autofill
                        .padding()
                    Button("Confirm", role: .destructive) {
                        // Proceed with account closure
                        viewModel.closeAccount(password: password) { result in
                            switch result {
                            case .success(let success):
                                if success {
                                    showAlert = true
                                } else {
                                    errorMessage = "Failed to close account."
                                    showErrorAlert = true
                                }
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                showErrorAlert = true
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
                //                message: {
                //                    Text("Deleting your account will remove all your 3D scanned models.")
                //                }
            }
            .navigationTitle("Close Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCloseAccountView = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // Alert for successful account closure
            .alert("Account Closed", isPresented: $showAlert) {
                Text("Your account has been successfully closed.")
            }
            // Alert for incorrect password
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
        //        .disabled(true)
        //        modal views which need not be scrolled have their scroll disabled
    }
}

struct CloseAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CloseAccountView(showingCloseAccountView: .constant(true))
    }
}
