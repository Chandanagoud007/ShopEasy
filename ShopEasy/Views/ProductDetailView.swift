import SwiftUI
import SafariServices

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedMerchant: Merchant?
    @State private var showingSafari = false
    @State private var merchantURL: URL?
    @State private var showingAddedToCart = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product image placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fill)
                    
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 6)
                    
                    Text("Available from \(product.merchants.count) merchants")
                        .font(.subheadline)
                        .padding(.bottom, 6)
                    
                    Divider()
                    
                    Text("Select a merchant")
                        .font(.headline)
                        .padding(.vertical, 4)
                }
                .padding(.horizontal)
                
                // Merchant options
                ForEach(product.merchants) { merchant in
                    MerchantOptionView(
                        merchant: merchant,
                        isSelected: selectedMerchant?.id == merchant.id,
                        onSelect: {
                            selectedMerchant = merchant
                        },
                        onLink: {
                            if let url = URL(string: merchant.link) {
                                merchantURL = url
                                showingSafari = true
                            }
                        }
                    )
                }
            }
        }
        .navigationTitle("Product Details")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: addToCart) {
                    Text("Add to Cart")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedMerchant == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedMerchant == nil)
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingSafari) {
            if let url = merchantURL {
                SafariView(url: url)
            }
        }
        .overlay(
            showingAddedToCart ?
            VStack {
                Spacer()
                Text("Added to cart!")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 80)
            }
            .transition(.move(edge: .bottom))
            : nil
        )
        .animation(.easeInOut(duration: 0.3), value: showingAddedToCart)
    }
    
    private func addToCart() {
        guard let merchant = selectedMerchant else { return }
        cartManager.addToCart(product: product, merchant: merchant)
        
        // Show confirmation
        withAnimation {
            showingAddedToCart = true
        }
        
        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingAddedToCart = false
            }
        }
    }
}

struct MerchantOptionView: View {
    let merchant: Merchant
    let isSelected: Bool
    let onSelect: () -> Void
    let onLink: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: merchant.iconName)
                        .foregroundColor(.blue)
                    
                    Text(merchant.name)
                        .font(.headline)
                }
                
                Text("$\(String(format: "%.2f", merchant.price))")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(merchant.formattedDelivery)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Button(action: onSelect) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                
                Button(action: onLink) {
                    Label("Visit", systemImage: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
