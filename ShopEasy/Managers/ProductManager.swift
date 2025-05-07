import Foundation
import FirebaseFirestore

class ProductManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var searchResults: [Product] = []
    
    private let db = Firestore.firestore()
    
    init() {
        // Initially we'll use demo products instead of fetching from Firebase
        loadDemoProducts()
    }
    
    func fetchProducts(for category: String? = nil) {
        isLoading = true
        
        var query: Query = db.collection("products")
        
        if let category = category {
            query = query.whereField("category", isEqualTo: category)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No product documents")
                return
            }
            
            self.products = documents.compactMap { document -> Product? in
                try? document.data(as: Product.self)
            }
        }
    }
    
    func searchProducts(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        let lowercaseQuery = query.lowercased()
        
        // In a real app, you would use Firebase query capabilities
        // For now, we'll filter the demo products locally
        searchResults = demoProducts.filter {
            $0.name.lowercased().contains(lowercaseQuery) ||
            $0.description.lowercased().contains(lowercaseQuery)
        }
        isLoading = false
    }
    
    // For demo purposes
    func loadDemoProducts() {
        products = demoProducts
    }
    
    func getProductsForCategory(_ category: String) -> [Product] {
        return demoProducts.filter { $0.category == category }
    }
}

// Demo products for development
let demoProducts: [Product] = [
    // Electronics
    Product(
        id: "1",
        name: "Wireless Earbuds",
        description: "True wireless earbuds with noise cancellation",
        category: "Electronics",
        imageURL: "https://placeholder.com/earbuds",
        merchants: [
            Merchant(name: "TechStore", price: 129.99, deliveryDays: 1, link: "https://techstore.com/earbuds", iconName: "cart"),
            Merchant(name: "ElectroMart", price: 119.99, deliveryDays: 3, link: "https://electromart.com/earbuds", iconName: "cube"),
            Merchant(name: "GadgetZone", price: 139.99, deliveryDays: 0, link: "https://gadgetzone.com/earbuds", iconName: "gift")
        ]
    ),
    Product(
        id: "2",
        name: "Smart Watch",
        description: "Fitness tracker with heart rate monitor and notifications",
        category: "Electronics",
        imageURL: "https://placeholder.com/smartwatch",
        merchants: [
            Merchant(name: "TechStore", price: 199.99, deliveryDays: 1, link: "https://techstore.com/smartwatch", iconName: "cart"),
            Merchant(name: "FitGear", price: 189.99, deliveryDays: 2, link: "https://fitgear.com/smartwatch", iconName: "figure.walk")
        ]
    ),
    
    // Clothing
    Product(
        id: "3",
        name: "Classic T-Shirt",
        description: "100% cotton t-shirt in various colors",
        category: "Clothing",
        imageURL: "https://placeholder.com/tshirt",
        merchants: [
            Merchant(name: "FashionHub", price: 24.99, deliveryDays: 2, link: "https://fashionhub.com/tshirt", iconName: "tshirt"),
            Merchant(name: "StyleStore", price: 29.99, deliveryDays: 1, link: "https://stylestore.com/tshirt", iconName: "bag"),
            Merchant(name: "ClothesOutlet", price: 19.99, deliveryDays: 4, link: "https://clothesoutlet.com/tshirt", iconName: "tag")
        ]
    ),
    Product(
        id: "4",
        name: "Running Shoes",
        description: "Lightweight running shoes with cushioned sole",
        category: "Clothing",
        imageURL: "https://placeholder.com/shoes",
        merchants: [
            Merchant(name: "SportsWorld", price: 89.99, deliveryDays: 2, link: "https://sportsworld.com/shoes", iconName: "figure.run"),
            Merchant(name: "FitGear", price: 99.99, deliveryDays: 1, link: "https://fitgear.com/shoes", iconName: "figure.walk")
        ]
    ),
    
    // Home & Kitchen
    Product(
        id: "5",
        name: "Coffee Maker",
        description: "Programmable coffee maker with timer",
        category: "Home & Kitchen",
        imageURL: "https://placeholder.com/coffeemaker",
        merchants: [
            Merchant(name: "HomeSupplies", price: 59.99, deliveryDays: 3, link: "https://homesupplies.com/coffeemaker", iconName: "house"),
            Merchant(name: "KitchenWare", price: 64.99, deliveryDays: 1, link: "https://kitchenware.com/coffeemaker", iconName: "cup.and.saucer")
        ]
    ),
    
    // Beauty
    Product(
        id: "6",
        name: "Facial Cleanser",
        description: "Gentle facial cleanser for all skin types",
        category: "Beauty",
        imageURL: "https://placeholder.com/cleanser",
        merchants: [
            Merchant(name: "BeautyShop", price: 16.99, deliveryDays: 2, link: "https://beautyshop.com/cleanser", iconName: "drop"),
            Merchant(name: "GlamStore", price: 14.99, deliveryDays: 3, link: "https://glamstore.com/cleanser", iconName: "sparkles")
        ]
    ),
    
    // Sports
    Product(
        id: "7",
        name: "Yoga Mat",
        description: "Non-slip yoga mat for home workouts",
        category: "Sports",
        imageURL: "https://placeholder.com/yogamat",
        merchants: [
            Merchant(name: "SportsWorld", price: 32.99, deliveryDays: 2, link: "https://sportsworld.com/yogamat", iconName: "figure.run"),
            Merchant(name: "FitGear", price: 29.99, deliveryDays: 1, link: "https://fitgear.com/yogamat", iconName: "figure.walk")
        ]
    ),
    
    // Books
    Product(
        id: "8",
        name: "Bestselling Novel",
        description: "The latest bestselling fiction novel",
        category: "Books",
        imageURL: "https://placeholder.com/book",
        merchants: [
            Merchant(name: "BookStore", price: 14.99, deliveryDays: 1, link: "https://bookstore.com/bestseller", iconName: "book"),
            Merchant(name: "ReadersHaven", price: 12.99, deliveryDays: 3, link: "https://readershaven.com/bestseller", iconName: "text.book.closed")
        ]
    ),
    
    // Toys
    Product(
        id: "9",
        name: "Building Blocks Set",
        description: "Creative building blocks for children",
        category: "Toys",
        imageURL: "https://placeholder.com/blocks",
        merchants: [
            Merchant(name: "ToyWorld", price: 24.99, deliveryDays: 2, link: "https://toyworld.com/blocks", iconName: "car"),
            Merchant(name: "KidsZone", price: 22.99, deliveryDays: 1, link: "https://kidszone.com/blocks", iconName: "gamecontroller")
        ]
    ),
    
    // Grocery
    Product(
        id: "10",
        name: "Organic Snack Box",
        description: "Assortment of healthy organic snacks",
        category: "Grocery",
        imageURL: "https://placeholder.com/snackbox",
        merchants: [
            Merchant(name: "OrganicMarket", price: 29.99, deliveryDays: 1, link: "https://organicmarket.com/snackbox", iconName: "leaf"),
            Merchant(name: "HealthStore", price: 32.99, deliveryDays: 0, link: "https://healthstore.com/snackbox", iconName: "heart")
        ]
    )
]
