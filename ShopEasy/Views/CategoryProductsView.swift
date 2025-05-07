import SwiftUI

struct CategoryProductsView: View {
    let category: String
    @StateObject private var productManager = ProductManager()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if productManager.isLoading {
                    ProgressView()
                        .padding()
                } else if productManager.products.isEmpty {
                    Text("No products found in this category")
                        .padding()
                } else {
                    ForEach(productManager.products.filter { $0.category == category }) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            ProductCardView(product: product)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category)
        .onAppear {
            productManager.loadDemoProducts() // Using demo products for now
        }
    }
}

struct ProductCardView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product image placeholder
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(8)
                
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(product.formattedPriceRange)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(product.merchants.count) merchants")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .foregroundColor(.primary) // Ensure text is readable against the background
    }
}
