import SwiftUI

struct RegisterView: View {
    
    @StateObject var viewModel = RegisterViewViewModel()
    @StateObject var loginViewModel = LoginViewViewModel()
    
    @State private var isUppercaseValid = false
    @State private var isNumberValid = false
    @State private var isSpecialCharacterValid = false
    @State private var isLengthValid = false
    @State private var isPasswordValid = false
    @State private var isUsernameValid = false
    @State private var isEmailValid = false
    
    var body: some View {
        VStack {
            VStack {
                Image("register")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .shadow(radius: 5)
            }
            
            VStack {
                TextField("Username", text: $viewModel.name)
                    .foregroundColor(.white)
                //                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .onChange(of: viewModel.name) { newValue in
                        isUsernameValid = !newValue.isEmpty
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
                    .onChange(of: viewModel.email) { newValue in
                        isEmailValid = isValidEmail(newValue)
                    }
                
                SecureField("Password", text: $viewModel.password)
                    .foregroundColor(.white)
                    .onChange(of: viewModel.password) { newValue in
                        validatePassword(newValue)
                    }
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                if (!isPasswordValid) {
                    VStack(alignment: .leading) {
                        passwordRequirement(text: "At least one uppercase letter", isValid: isUppercaseValid)
                        passwordRequirement(text: "At least one number", isValid: isNumberValid)
                        passwordRequirement(text: "At least one special character", isValid: isSpecialCharacterValid)
                        passwordRequirement(text: "At least 8 characters long", isValid: isLengthValid)
                    }
                    .foregroundColor(.white)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                TLButton(title: "Register", background: isButtonEnabled() ? .green : .gray) {
                    viewModel.register()
                }
                .disabled(!isButtonEnabled()) // Disable button if not all fields are valid
                
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    Text("or")
                        .padding(.horizontal, 10)
                        .foregroundColor(.gray)
                    
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
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(15)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 50)
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkTeal, Color.darkTeal, Color.black]), startPoint: .top, endPoint: .bottom))
    }
    
    private func validatePassword(_ password: String) {
        // Define regex patterns for password requirements
        let uppercasePattern = "[A-Z]"
        let numberPattern = "[0-9]"
        let specialCharacterPattern = "[!@#$%^&*]"
        let lengthRequirement = password.count >= 8
        
        // Check if the password meets each requirement
        isUppercaseValid = password.range(of: uppercasePattern, options: .regularExpression) != nil
        isNumberValid = password.range(of: numberPattern, options: .regularExpression) != nil
        isSpecialCharacterValid = password.range(of: specialCharacterPattern, options: .regularExpression) != nil
        isLengthValid = lengthRequirement
        isPasswordValid = isUppercaseValid && isNumberValid && isSpecialCharacterValid && isLengthValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
        return email.range(of: emailPattern, options: .regularExpression) != nil
    }
    
    private func isButtonEnabled() -> Bool {
        return isUsernameValid && isEmailValid && isPasswordValid
    }
    
    private func passwordRequirement(text: String, isValid: Bool) -> some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
            Text(text)
        }
    }
}

#Preview {
    RegisterView()
}
