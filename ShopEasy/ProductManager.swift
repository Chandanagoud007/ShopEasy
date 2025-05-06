//
//  ProductManager.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 06/05/25.
//

import Foundation
import FirebaseAuth
import Combine

class ProductManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var productsByCategory: [String: [Product]] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firebaseService = FirebaseService()
    
    // MARK: - Sample Data for Testing
    
    static var sampleProducts: [Product] {
        [
            Product(
                id: "1",
                name: "iPhone 15 Pro",
                description: "Apple's latest iPhone with A17 Pro chip, 48MP camera and Action button.",
                category: "Electronics",
                imageUrl: "iphone15",
                merchants: [
                    MerchantOffer(
                        merchantId: "apple",
                        merchantName: "Apple Store",
                        price: 999.0,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        link: "https://apple.com/iphone-15-pro",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "amazon",
                        merchantName: "Amazon",
                        price: 989.0,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                        link: "https://amazon.com/iphone-15-pro",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "bestbuy",
                        merchantName: "Best Buy",
                        price: 979.0,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                        link: "https://bestbuy.com/iphone-15-pro",
                        inStock: true
                    )
                ]
            ),
            Product(
                id: "2",
                name: "Samsung Galaxy S24 Ultra",
                description: "Samsung's flagship phone with Snapdragon 8 Gen 3, 200MP camera and S Pen.",
                category: "Electronics",
                imageUrl: "galaxys24",
                merchants: [
                    MerchantOffer(
                        merchantId: "samsung",
                        merchantName: "Samsung Store",
                        price: 1199.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        link: "https://samsung.com/galaxy-s24-ultra",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "amazon",
                        merchantName: "Amazon",
                        price: 1149.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                        link: "https://amazon.com/galaxy-s24-ultra",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "bestbuy",
                        merchantName: "Best Buy",
                        price: 1179.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        link: "https://bestbuy.com/galaxy-s24-ultra",
                        inStock: false
                    )
                ]
            ),
            Product(
                id: "3",
                name: "MacBook Air M3",
                description: "Apple's thinnest and lightest laptop with M3 chip and all-day battery life.",
                category: "Electronics",
                imageUrl: "macbookair",
                merchants: [
                    MerchantOffer(
                        merchantId: "apple",
                        merchantName: "Apple Store",
                        price: 1299.0,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                        link: "https://apple.com/macbook-air",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "amazon",
                        merchantName: "Amazon",
                        price: 1249.0,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        link: "https://amazon.com/macbook-air",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "bestbuy",
                        merchantName: "Best Buy",
                        price: 1279.0,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
                        link: "https://bestbuy.com/macbook-air",
                        inStock: true
                    )
                ]
            ),
            Product(
                id: "4",
                name: "Nike Air Zoom Pegasus 40",
                description: "Versatile running shoe with React foam midsole and Zoom Air cushioning.",
                category: "Sports",
                imageUrl: "nikepegasus",
                merchants: [
                    MerchantOffer(
                        merchantId: "nike",
                        merchantName: "Nike",
                        price: 130.0,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                        link: "https://nike.com/pegasus-40",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "amazon",
                        merchantName: "Amazon",
                        price: 119.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                        link: "https://amazon.com/nike-pegasus-40",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "footlocker",
                        merchantName: "Foot Locker",
                        price: 124.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        link: "https://footlocker.com/nike-pegasus-40",
                        inStock: true
                    )
                ]
            ),
            Product(
                id: "5",
                name: "Instant Pot Duo Plus",
                description: "9-in-1 pressure cooker that replaces multiple kitchen appliances.",
                category: "Home & Kitchen",
                imageUrl: "instantpot",
                merchants: [
                    MerchantOffer(
                        merchantId: "amazon",
                        merchantName: "Amazon",
                        price: 129.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                        link: "https://amazon.com/instant-pot",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "walmart",
                        merchantName: "Walmart",
                        price: 119.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        link: "https://walmart.com/instant-pot",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "target",
                        merchantName: "Target",
                        price: 124.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                        link: "https://target.com/instant-pot",
                        inStock: false
                    )
                ]
            ),
            Product(
                id: "6",
                name: "The Alchemist",
                description: "Paulo Coelho's masterpiece about following your dreams.",
                category: "Books",
                imageUrl: "alchemist",
                merchants: [
                    MerchantOffer(
                        merchantId: "amazon",
                        merchantName: "Amazon",
                        price: 12.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                        link: "https://amazon.com/the-alchemist",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "barnesnoble",
                        merchantName: "Barnes & Noble",
                        price: 14.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                        link: "https://barnesnoble.com/the-alchemist",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "booksamillion",
                        merchantName: "Books-A-Million",
                        price: 13.49,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
                        link: "https://booksamillion.com/the-alchemist",
                        inStock: true
                    )
                ]
            ),
            Product(
                id: "7",
                name: "Dyson Airwrap",
                description: "Multi-styler for different hair types and styles with no extreme heat.",
                category: "Beauty",
                imageUrl: "dysonairwrap",
                merchants: [
                    MerchantOffer(
                        merchantId: "dyson",
                        merchantName: "Dyson",
                        price: 599.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        link: "https://dyson.com/airwrap",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "sephora",
                        merchantName: "Sephora",
                        price: 599.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                        link: "https://sephora.com/dyson-airwrap",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "ulta",
                        merchantName: "Ulta Beauty",
                        price: 599.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
                        link: "https://ulta.com/dyson-airwrap",
                        inStock: false
                    )
                ]
            ),
            Product(
                id: "8",
                name: "LEGO Star Wars Millennium Falcon",
                description: "Iconic Star Wars spaceship with detailed interior and minifigures.",
                category: "Toys",
                imageUrl: "legomillenniumfalcon",
                merchants: [
                    MerchantOffer(
                        merchantId: "lego",
                        merchantName: "LEGO Shop",
                        price: 169.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                        link: "https://lego.com/millennium-falcon",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "amazon",
                        merchantName: "Amazon",
                        price: 159.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                        link: "https://amazon.com/lego-millennium-falcon",
                        inStock: true
                    ),
                    MerchantOffer(
                        merchantId: "walmart",
                        merchantName: "Walmart",
                        price: 164.99,
                        deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        link: "https://walmart.com/lego-millennium-falcon",
                        inStock: true
                    )
                ]
            )
        ]
    }
    
    // MARK: - Fetch Methods
    
    // Toggle this to use Firebase or local mock data
    let useFirebase = false
    
    func fetchAllProducts() {
        isLoading = true
        
        if useFirebase {
            Task {
                do {
                    let fetchedProducts = try await firebaseService.fetchProducts()
                    
                    await MainActor.run {
                        self.products = fetchedProducts
                        self.isLoading = false
                        self.error = nil
                        self.organizeProductsByCategory()
                    }
                } catch {
                    await MainActor.run {
                        self.error = error
                        self.isLoading = false
                    }
                    print("Error fetching products: \(error.localizedDescription)")
                }
            }
        } else {
            // Use mock data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.products = ProductManager.sampleProducts
                self.isLoading = false
                self.error = nil
                self.organizeProductsByCategory()
            }
        }
    }
    
    func fetchProductsByCategory(category: String) {
        isLoading = true
        
        if useFirebase {
            Task {
                do {
                    let fetchedProducts = try await firebaseService.fetchProductsByCategory(category: category)
                    
                    await MainActor.run {
                        self.productsByCategory[category] = fetchedProducts
                        self.isLoading = false
                        self.error = nil
                    }
                } catch {
                    await MainActor.run {
                        self.error = error
                        self.isLoading = false
                    }
                    print("Error fetching products by category: \(error.localizedDescription)")
                }
            }
        } else {
            // Use mock data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.productsByCategory[category] = ProductManager.sampleProducts.filter { $0.category == category }
                self.isLoading = false
                self.error = nil
            }
        }
    }
    
    private func organizeProductsByCategory() {
        var categorized: [String: [Product]] = [:]
        
        for product in products {
            if categorized[product.category] == nil {
                categorized[product.category] = []
            }
            categorized[product.category]?.append(product)
        }
        
        productsByCategory = categorized
    }
    
    // MARK: - Firebase Upload Method
    
    func uploadSampleProductsToFirebase() {
        let db = FirebaseFirestore.Firestore.firestore()
        
        for product in ProductManager.sampleProducts {
            guard let productId = product.id else { continue }
            
            do {
                try db.collection("products").document(productId).setData(from: product)
            } catch {
                print("Error uploading product \(productId): \(error.localizedDescription)")
            }
        }
    }
}
