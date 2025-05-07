import SwiftUI

struct ProductSearchView: View {
    @StateObject private var productManager = ProductManager()
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search products", text: $searchText)
                        .autocapitalization(.none)
                        .onChange(of: searchText) { _ in
                            productManager.searchProducts(query: searchText)
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            productManager.searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if isSearching {
                    Button("Cancel") {
                        searchText = ""
                        isSearching = false
                        hideKeyboard()
                        productManager.searchResults = []
                    }
                    .transition(.move(edge: .trailing))
                }
            }
            .padding()
            .animation(.default, value: isSearching)
            .onTapGesture {
                isSearching = true
            }
            
            // Results
            if productManager.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if searchText.isEmpty {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Popular categories")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(["Electronics", "Clothing", "Books", "Home & Kitchen"], id: \.self) { category in
                                    NavigationLink(destination: CategoryProductsView(category: category)) {
                                        Text(category)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Recently viewed")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        Text("Search for products to get started")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .padding(.vertical)
                }
            } else if productManager.searchResults.isEmpty {
                Spacer()
                Text("No products found for '\(searchText)'")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(productManager.searchResults) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductCardView(product: product)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Search")
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
