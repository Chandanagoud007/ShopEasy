//
//  FirebaseService.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 06/05/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import Combine

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    // MARK: - Product Methods
    
    /// Fetch all products
    func fetchProducts() async throws -> [Product] {
        let snapshot = try await db.collection("products").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Product.self)
        }
    }
    
    /// Fetch products by category
    func fetchProductsByCategory(category: String) async throws -> [Product] {
        let snapshot = try await db.collection("products")
            .whereField("category", isEqualTo: category)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Product.self)
        }
    }
    
    /// Fetch a single product by ID
    func fetchProduct(id: String) async throws -> Product {
        let docRef = db.collection("products").document(id)
        let document = try await docRef.getDocument()
        
        guard let product = try? document.data(as: Product.self) else {
            throw NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
        }
        
        return product
    }
    
    // MARK: - Cart Methods
    
    /// Fetch user's cart
    func fetchCart(userId: String) async throws -> [CartItem] {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("carts").document(userId)
        let document = try await docRef.getDocument()
        
        if document.exists {
            if let data = document.data(), let items = data["items"] as? [[String: Any]] {
                return items.compactMap { itemDict in
                    guard
                        let productId = itemDict["productId"] as? String,
                        let merchantId = itemDict["merchantId"] as? String,
                        let quantity = itemDict["quantity"] as? Int,
                        let addedAtTimestamp = itemDict["addedAt"] as? Timestamp
                    else {
                        return nil
                    }
                    
                    return CartItem(
                        productId: productId,
                        merchantId: merchantId,
                        quantity: quantity,
                        addedAt: addedAtTimestamp.dateValue()
                    )
                }
            }
        }
        
        return []
    }
    
    /// Add item to cart
    func addToCart(userId: String, productId: String, merchantId: String, quantity: Int) async throws {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("carts").document(userId)
        let cartItem: [String: Any] = [
            "productId": productId,
            "merchantId": merchantId,
            "quantity": quantity,
            "addedAt": Timestamp(date: Date())
        ]
        
        // Check if cart exists
        let document = try await docRef.getDocument()
        
        if document.exists {
            // Update existing cart
            try await docRef.updateData([
                "items": FieldValue.arrayUnion([cartItem])
            ])
        } else {
            // Create new cart
            try await docRef.setData([
                "items": [cartItem]
            ])
        }
    }
    
    /// Remove item from cart
    func removeFromCart(userId: String, productId: String, merchantId: String) async throws {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("carts").document(userId)
        let document = try await docRef.getDocument()
        
        if document.exists {
            if let data = document.data(), var items = data["items"] as? [[String: Any]] {
                // Find and remove the item
                items.removeAll { item in
                    guard let itemProductId = item["productId"] as? String,
                          let itemMerchantId = item["merchantId"] as? String else {
                        return false
                    }
                    return itemProductId == productId && itemMerchantId == merchantId
                }
                
                // Update cart with filtered items
                try await docRef.updateData([
                    "items": items
                ])
            }
        }
    }
    
    /// Clear entire cart
    func clearCart(userId: String) async throws {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("carts").document(userId)
        try await docRef.updateData([
            "items": []
        ])
    }
    
    // MARK: - Wishlist Methods
    
    /// Fetch user's wishlist
    func fetchWishlist(userId: String) async throws -> [WishlistItem] {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("wishlists").document(userId)
        let document = try await docRef.getDocument()
        
        if document.exists {
            if let data = document.data(), let items = data["items"] as? [[String: Any]] {
                return items.compactMap { itemDict in
                    guard
                        let productId = itemDict["productId"] as? String,
                        let addedAtTimestamp = itemDict["addedAt"] as? Timestamp
                    else {
                        return nil
                    }
                    
                    return WishlistItem(
                        productId: productId,
                        addedAt: addedAtTimestamp.dateValue()
                    )
                }
            }
        }
        
        return []
    }
    
    /// Add item to wishlist
    func addToWishlist(userId: String, productId: String) async throws {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("wishlists").document(userId)
        let wishlistItem: [String: Any] = [
            "productId": productId,
            "addedAt": Timestamp(date: Date())
        ]
        
        // Check if wishlist exists
        let document = try await docRef.getDocument()
        
        if document.exists {
            // Update existing wishlist
            try await docRef.updateData([
                "items": FieldValue.arrayUnion([wishlistItem])
            ])
        } else {
            // Create new wishlist
            try await docRef.setData([
                "items": [wishlistItem]
            ])
        }
    }
    
    /// Remove item from wishlist
    func removeFromWishlist(userId: String, productId: String) async throws {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("wishlists").document(userId)
        let document = try await docRef.getDocument()
        
        if document.exists {
            if let data = document.data(), var items = data["items"] as? [[String: Any]] {
                // Find and remove the item
                items.removeAll { item in
                    guard let itemProductId = item["productId"] as? String else {
                        return false
                    }
                    return itemProductId == productId
                }
                
                // Update wishlist with filtered items
                try await docRef.updateData([
                    "items": items
                ])
            }
        }
    }
    
    /// Check if product is in wishlist
    func isInWishlist(userId: String, productId: String) async throws -> Bool {
        let wishlistItems = try await fetchWishlist(userId: userId)
        return wishlistItems.contains(where: { $0.productId == productId })
    }
    
    // MARK: - Order Methods
    
    /// Fetch user's orders
    func fetchOrders(userId: String) async throws -> [Order] {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("orders").document(userId)
        let document = try await docRef.getDocument()
        
        if document.exists {
            if let data = document.data(), let orderItems = data["orderItems"] as? [[String: Any]] {
                return orderItems.compactMap { itemDict in
                    guard
                        let orderId = itemDict["orderId"] as? String,
                        let productId = itemDict["productId"] as? String,
                        let merchantId = itemDict["merchantId"] as? String,
                        let quantity = itemDict["quantity"] as? Int,
                        let price = itemDict["price"] as? Double,
                        let statusRaw = itemDict["status"] as? String,
                        let orderDateTimestamp = itemDict["orderDate"] as? Timestamp,
                        let deliveryDateTimestamp = itemDict["deliveryDate"] as? Timestamp,
                        let isDelivered = itemDict["isDelivered"] as? Bool
                    else {
                        return nil
                    }
                    
                    let status = OrderStatus(rawValue: statusRaw) ?? .pending
                    
                    return Order(
                        orderId: orderId,
                        productId: productId,
                        merchantId: merchantId,
                        quantity: quantity,
                        price: price,
                        status: status,
                        orderDate: orderDateTimestamp.dateValue(),
                        deliveryDate: deliveryDateTimestamp.dateValue(),
                        isDelivered: isDelivered
                    )
                }
            }
        }
        
        return []
    }
    
    /// Place order (move items from cart to orders)
    func placeOrder(userId: String, cartItems: [CartItem], products: [Product]) async throws {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let orderDocRef = db.collection("orders").document(userId)
        let cartDocRef = db.collection("carts").document(userId)
        
        // Prepare order items
        var orderItems: [[String: Any]] = []
        let orderId = UUID().uuidString
        let orderDate = Date()
        
        for cartItem in cartItems {
            guard let product = products.first(where: { $0.id == cartItem.productId }),
                  let merchantOffer = product.merchants.first(where: { $0.merchantId == cartItem.merchantId }) else {
                continue
            }
            
            let orderItem: [String: Any] = [
                "orderId": orderId,
                "productId": cartItem.productId,
                "merchantId": cartItem.merchantId,
                "quantity": cartItem.quantity,
                "price": merchantOffer.price,
                "status": OrderStatus.pending.rawValue,
                "orderDate": Timestamp(date: orderDate),
                "deliveryDate": Timestamp(date: merchantOffer.deliveryDate),
                "isDelivered": false
            ]
            
            orderItems.append(orderItem)
        }
        
        // Check if orders document exists
        let orderDoc = try await orderDocRef.getDocument()
        
        if orderDoc.exists {
            // Append to existing orders
            if let data = orderDoc.data(), var existingOrderItems = data["orderItems"] as? [[String: Any]] {
                existingOrderItems.append(contentsOf: orderItems)
                try await orderDocRef.updateData([
                    "orderItems": existingOrderItems
                ])
            } else {
                try await orderDocRef.updateData([
                    "orderItems": orderItems
                ])
            }
        } else {
            // Create new orders document
            try await orderDocRef.setData([
                "orderItems": orderItems
            ])
        }
        
        // Clear cart after order is placed
        try await clearCart(userId: userId)
    }
    
    /// Mark order as delivered
    func markOrderAsDelivered(userId: String, orderId: String, productId: String) async throws {
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
        }
        
        let docRef = db.collection("orders").document(userId)
        let document = try await docRef.getDocument()
        
        if document.exists {
            if let data = document.data(), var orderItems = data["orderItems"] as? [[String: Any]] {
                // Find and update the order item
                for (index, var orderItem) in orderItems.enumerated() {
                    if let itemOrderId = orderItem["orderId"] as? String,
                       let itemProductId = orderItem["productId"] as? String,
                       itemOrderId == orderId && itemProductId == productId {
                        orderItem["status"] = OrderStatus.delivered.rawValue
                        orderItem["isDelivered"] = true
                        orderItems[index] = orderItem
                        break
                    }
                }
                
                // Update orders with updated items
                try await docRef.updateData([
                    "orderItems": orderItems
                ])
            }
        }
    }
}
