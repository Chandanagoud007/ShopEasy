import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - Product Model
struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var category: String
    var imageUrl: String
    var merchants: [MerchantOffer]
    
    // Helper to get lowest price from all merchants
    var lowestPrice: Double {
        merchants.map { $0.price }.min() ?? 0.0
    }
    
    // Helper to determine if any merchant has the product in stock
    var isAvailable: Bool {
        merchants.contains { $0.inStock }
    }
}

// MARK: - Merchant Offer Model
struct MerchantOffer: Identifiable, Codable {
    var id: String { merchantId }
    var merchantId: String
    var merchantName: String
    var price: Double
    var deliveryDate: Date
    var link: String
    var inStock: Bool
}

// MARK: - Cart Item Model
struct CartItem: Identifiable, Codable {
    var id: String { "\(productId)-\(merchantId)" }
    var productId: String
    var merchantId: String
    var quantity: Int
    var addedAt: Date
    
    // These fields are not stored in Firestore but used for UI
    var product: Product?
    var merchantOffer: MerchantOffer?
}

// MARK: - Wishlist Item Model
struct WishlistItem: Identifiable, Codable {
    var id: String { productId }
    var productId: String
    var addedAt: Date
    
    // Not stored in Firestore but used for UI
    var product: Product?
}

// MARK: - Order Model
struct Order: Identifiable, Codable {
    var id: String { orderId }
    var orderId: String
    var productId: String
    var merchantId: String
    var quantity: Int
    var price: Double
    var status: OrderStatus
    var orderDate: Date
    var deliveryDate: Date
    var isDelivered: Bool
    
    // Not stored in Firestore but used for UI
    var product: Product?
    var merchantOffer: MerchantOffer?
}

enum OrderStatus: String, Codable {
    case pending = "pending"
    case delivered = "delivered"
}
