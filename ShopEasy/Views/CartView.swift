import SwiftUI
import SafariServices

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showingSafari = false
    @State private var merchantURL: URL?
    
    var body: some View {
        VStack {
            if cartManager.isLoading {
                ProgressView()
            } else if cartManager.cartItems.isEmpty {
                emptyCartView
            } else {
                cartItemsView
            }
        }
        .navigationTitle("Shopping Cart")
        .sheet(isPresented: $showingSafari) {
            if let url = merchantURL {
                SafariView(url: url)
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "cart")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add items to start shopping")
                .foregroundColor(.secondary)
            
            NavigationLink(destination: BrowseCategoriesView()) {
                Text("Browse Categories")
                    .fontWeight(.semibold)
                    .frame(width: 200)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
    
    private var cartItemsView: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(cartManager.cartItems) { item in
                        CartItemRow(item: item, onRemove: {
                            if let id = item.id {
                                cartManager.removeFromCart(cartId: id)
                            }
                        }, onLink: {
                            if let url = URL(string: item.merchantLink) {
                                merchantURL = url
                                showingSafari = true
                            }
                        })
                    }
                }
                .padding()
            }
            
            // Cart summary
            VStack(spacing: 10) {
                HStack {
                    Text("Total")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", cartManager.cartItems.reduce(0) { $0 + $1.price }))")
                        .fontWeight(.bold)
                }
                
                Text("Items in your cart are not reserved. Check each merchant site to complete your purchase.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                
                Button(action: {
                    cartManager.clearCart()
                }) {
                    Text("Clear Cart")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .top
            )
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    let onRemove: () -> Void
    let onLink: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Product image placeholder
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.productName)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", item.price))")
                    .fontWeight(.semibold)
                
                HStack {
                    Image(systemName: "cart")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text(item.merchantName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(item.formattedDelivery)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: onLink) {
                    Text("Visit merchant")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 2)
            }
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding(.leading, 5)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
