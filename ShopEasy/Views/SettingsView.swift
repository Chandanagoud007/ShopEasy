import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @ObservedObject var authState: AuthState
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var showingLogoutAlert: Bool = false

    var body: some View {
        List {
            Section(header: Text("Profile")) {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .padding(.trailing, 10)

                    VStack(alignment: .leading) {
                        Text(username)
                            .font(.headline)
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }

            Section(header: Text("Help & Support")) {
                NavigationLink("FAQ", destination: Text("Frequently Asked Questions"))
                NavigationLink("Contact Support", destination: Text("Contact us at support@shopeasy.com"))
                NavigationLink("About", destination: Text("ShopEasy App Version 1.0"))
            }

            Section {
                Button(role: .destructive) {
                    showingLogoutAlert = true
                } label: {
                    Label("Log Out", systemImage: "arrow.right.square.fill")
                }
                .alert("Log Out", isPresented: $showingLogoutAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Log Out", role: .destructive) {
                        logoutUser()
                    }
                } message: {
                    Text("Are you sure you want to log out?")
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear(perform: fetchUserDetails)
    }

    private func fetchUserDetails() {
        if let user = Auth.auth().currentUser {
            // Refresh user to ensure we have the latest data
            user.reload { error in
                if let error = error {
                    print("Error reloading user: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.username = user.displayName ?? "User"
                        self.email = user.email ?? "No email"
                    }
                }
            }
        }
    }

    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            authState.isSignedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(authState: AuthState())
        }
    }
}
