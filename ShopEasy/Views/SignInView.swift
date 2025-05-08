import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @ObservedObject var authState: AuthState

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Image("selogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150) // Adjust height as needed
                    .padding(.bottom, 40)


                VStack(spacing: 15) {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: {
                    Task {
                        await viewModel.signInWithEmail()
                        if viewModel.isSignedIn {
                            if let user = Auth.auth().currentUser {
                                authState.isSignedIn = true
                                authState.isEmailVerified = user.isEmailVerified
                            }
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    } else {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .alert(isPresented: Binding<Bool>(
                    get: { viewModel.errorMessage != nil || viewModel.passwordResetMessage != nil },
                    set: { _ in
                        viewModel.errorMessage = nil
                        viewModel.passwordResetMessage = nil
                    }
                )) {
                    Alert(title: Text(viewModel.errorMessage != nil ? "Error" : "Success"),
                          message: Text(viewModel.errorMessage ?? viewModel.passwordResetMessage ?? ""),
                          dismissButton: .default(Text("OK")))
                }

                Button(action: {
                    if viewModel.email.isEmpty {
                        viewModel.errorMessage = "Please enter your email to reset your password."
                    } else {
                        Task {
                            await viewModel.sendPasswordReset(to: viewModel.email)
                        }
                    }
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                .padding(.bottom, 15)

                HStack {
                    Text("Don't have an account?")
                    NavigationLink(destination: SignUpView(authState: authState)) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .font(.system(size: 16, weight: .bold))
                            .underline()
                    }
                }
                .padding(.bottom, 30)

                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                    Task {
                        await viewModel.signInGoogle()
                        if viewModel.isSignedIn {
                            DispatchQueue.main.async {
                                // Update both isSignedIn and isEmailVerified after Google sign-in
                                if let user = Auth.auth().currentUser {
                                    authState.isSignedIn = true
                                    authState.isEmailVerified = user.isEmailVerified
                                }
                            }
                        }
                    }
                }
                .padding()

                Spacer()
            }
            .padding()
            .navigationBarTitle("Sign In", displayMode: .inline)
        }
        .onAppear {
            checkAuthState()
        }
    }

    private func checkAuthState() {
        // This method now properly checks both authentication and email verification
        if let user = Auth.auth().currentUser {
            user.reload { (error) in
                if let error = error {
                    print("Failed to reload user: \(error)")
                    DispatchQueue.main.async {
                        self.authState.isSignedIn = false
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.authState.isSignedIn = true
                    self.authState.isEmailVerified = user.isEmailVerified
                }
            }
        } else {
            authState.isSignedIn = false
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(authState: AuthState())
    }
}
