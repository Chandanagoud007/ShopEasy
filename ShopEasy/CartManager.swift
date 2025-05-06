//
//  CartManager.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 06/05/25.
//

import Foundation
import FirebaseAuth
import Combine

// MARK: - Cart Manager
class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firebaseService = FirebaseService()
    private var cancellables = Set<AnyCancellable>()
    
    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        cartItems.reduce(0.0) { total, item in
            total + (item.merchantOffer?.price ?? 0.0) * Double(item.quantity)
        }
    }
    
    func fetchCart() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        Task {
            do {
                let items = try await firebaseService.fetchCart(userId: userId)
                
                // Load product details for each cart item
                var detailedItems: [CartItem] = []
                
                for var item in items {
                    do {
                        let product = try await firebaseService.fetchProduct(id: item.productId)
                        item.product = product
                        
                        if let merchantOffer = product.merchants.first(where: { $0.merchantId == item.merchantId }) {
                            item.merchantOffer = merchantOffer
                        }
                        
                        detailedItems.append(item)
                    } catch {
                        print("Error loading product details: \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    self.cartItems = detailedItems
                    self.isLoading = false
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("Error fetching cart: \(error.localizedDescription)")
            }
        }
    }
    
    func addToCart(product: Product, merchantOffer: MerchantOffer, quantity: Int = 1) {
        guard let userId = Auth.auth().currentUser?.uid, let productId = product.id else { return }
        
        Task {
            do {
                try await firebaseService.addToCart(
                    userId: userId,
                    productId: productId,
                    merchantId: merchantOffer.merchantId,
                    quantity: quantity
                )
                
                await MainActor.run {
                    // Check if item already exists in cart
                    if let index = self.cartItems.firstIndex(where: {
                        $0.productId == productId && $0.merchantId == merchantOffer.merchantId
                    }) {
                        // Update quantity
                        self.cartItems[index].quantity += quantity
                    } else {
                        // Add new item
                        let cartItem = CartItem(
                            productId: productId,
                            merchantId: merchantOffer.merchantId,
                            quantity: quantity,
                            addedAt: Date(),
                            product: product,
                            merchantOffer: merchantOffer
                        )
                        self.cartItems.append(cartItem)
                    }
                    
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error adding to cart: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFromCart(productId: String, merchantId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                try await firebaseService.removeFromCart(
                    userId: userId,
                    productId: productId,
                    merchantId: merchantId
                )
                
                await MainActor.run {
                    self.cartItems.removeAll {
                        $0.productId == productId && $0.merchantId == merchantId
                    }
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error removing from cart: \(error.localizedDescription)")
            }
        }
    }
    
    func clearCart() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                try await firebaseService.clearCart(userId: userId)
                
                await MainActor.run {
                    self.cartItems.removeAll()
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error clearing cart: \(error.localizedDescription)")
            }
        }
    }
    
    func updateQuantity(for productId: String, merchantId: String, quantity: Int) {
        guard quantity > 0 else {
            removeFromCart(productId: productId, merchantId: merchantId)
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // First remove the item, then add it with the new quantity
        Task {
            do {
                try await firebaseService.removeFromCart(
                    userId: userId,
                    productId: productId,
                    merchantId: merchantId
                )
                
                // Get the product data from our local cartItems
                if let cartItem = cartItems.first(where: {
                    $0.productId == productId && $0.merchantId == merchantId
                }) {
                    try await firebaseService.addToCart(
                        userId: userId,
                        productId: productId,
                        merchantId: merchantId,
                        quantity: quantity
                    )
                    
                    await MainActor.run {
                        if let index = self.cartItems.firstIndex(where: {
                            $0.productId == productId && $0.merchantId == merchantId
                        }) {
                            self.cartItems[index].quantity = quantity
                        }
                        self.error = nil
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error updating quantity: \(error.localizedDescription)")
            }
        }
    }
}
