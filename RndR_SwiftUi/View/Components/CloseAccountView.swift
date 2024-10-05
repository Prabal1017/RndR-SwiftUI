import SwiftUI

struct CloseAccountView: View {
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var isAccountClosed: Bool = false
    @Binding var showingCloseAccountView : Bool
    
    var body: some View {
        NavigationView{
                List{
                    
                    
                    
                    Section(header:
                                Text("warning"),
                            footer: Text("Closing your account is irreversible and it cannot be undone.")
                        .foregroundColor(.primary)
                        .textCase(nil)
                        )
                            {
                                      //empty section
                            }
                    
                    Section(header: Text("Deleting your account will remove all your 3D scanned models and you wont be able to access them.")
                        .foregroundColor(.primary)
                        .textCase(nil)
                    )
                        {
                            // Another empty section
                        }
                    
                    
                    Section{
                        SecureField("Password", text: $password)
                    }
                    
                    Section{
                        HStack{
                            Spacer()
                            Button{
                                closeAccount()
                            } label:{
                                Text("Close account")
                                    .foregroundColor(.red)
                            }
                            Spacer()
                        }
                    }
                }
                //            .listStyle(.plain)
                
                .navigationTitle("Close Account")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button{
                            showingCloseAccountView = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.primary)
                        }
                    }
                }
            
            }
        }
    
    private func closeAccount() {
        // Implement your account closing logic here
        // For now, we'll just show an alert
        if !password.isEmpty {
            showAlert = true
        } else {
            // Handle empty password case if necessary
        }
    }
}

struct CloseAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CloseAccountView(showingCloseAccountView: .constant(true))
    }
}
