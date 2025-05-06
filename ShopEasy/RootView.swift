import SwiftUI
import FirebaseAuth

class AuthState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isEmailVerified: Bool = false
}

struct RootView: View {
    @StateObject private var authState = AuthState()

    var body: some View {
        Group {
            if authState.isSignedIn && authState.isEmailVerified {
                HomePageView(authState: authState)
            } else {
                SignInView(authState: authState)
            }
        }
        .onAppear {
            checkAuthentication()
        }
    }
    
    private func checkAuthentication() {
        if let user = Auth.auth().currentUser {
            user.reload { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Failed to reload user: \(error)")
                        authState.isSignedIn = false
                        authState.isEmailVerified = false
                    } else {
                        authState.isSignedIn = true
                        authState.isEmailVerified = user.isEmailVerified
                        print("User is signed in: \(authState.isSignedIn)")
                        print("Email is verified: \(authState.isEmailVerified)")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                authState.isSignedIn = false
                authState.isEmailVerified = false
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
