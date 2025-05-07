import SwiftUI

struct HomePageView: View {
    @ObservedObject var authState: AuthState
    @StateObject private var cartManager = CartManager()
    @State private var selectedTab = 0
    
    var body: some View {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    ShopHomeTabView()
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

                NavigationStack {
                    CartView()
                }
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
                .badge(cartManager.totalItems)
                .tag(1)


                NavigationStack {
                    SettingsView(authState: authState)
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
            }
            .environmentObject(cartManager)
        }
    }

struct ShopHomeTabView: View {
    var body: some View {
        VStack(spacing: 20) {
            NavigationLink {
                BrowseCategoriesView()
            } label: {
                HomeCardView(title: "Browse Categories", image: "square.grid.2x2.fill", color: .purple)
            }
            
            NavigationLink {
                ProductSearchView()
            } label: {
                HomeCardView(title: "Search Products", image: "magnifyingglass", color: .orange)
            }
        }
        .padding()
        .navigationTitle("ShopEasy")
    }
}

struct HomeCardView: View {
    let title: String
    let image: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
            
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .frame(height: 80)
        .background(LinearGradient(gradient: Gradient(colors: [color, color.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 5)
    }
}
