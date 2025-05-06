//
//  WishlistManager.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 06/05/25.
//

import Foundation
import FirebaseAuth
import Combine


// MARK: - Wishlist Manager
class WishlistManager: ObservableObject {
    @Published var wishlistItems: [WishlistItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firebaseService = FirebaseService()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchWishlist() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        Task {
            do {
                let items = try await firebaseService.fetchWishlist(userId: userId)
                
                // Load product details for each wishlist item
                var detailedItems: [WishlistItem] = []
                
                for var item in items {
                    do {
                        let product = try await firebaseService.fetchProduct(id: item.productId)
                        item.product = product
                        detailedItems.append(item)
                    } catch {
                        print("Error loading product details: \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    self.wishlistItems = detailedItems
                    self.isLoading = false
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("Error fetching wishlist: \(error.localizedDescription)")
            }
        }
    }
    
    func addToWishlist(product: Product) {
        guard let userId = Auth.auth().currentUser?.uid, let productId = product.id else { return }
        
        Task {
            do {
                try await firebaseService.addToWishlist(userId: userId, productId: productId)
                
                await MainActor.run {
                    // Check if item already exists in wishlist
                    if !self.wishlistItems.contains(where: { $0.productId == productId }) {
                        let wishlistItem = WishlistItem(
                            productId: productId,
                            addedAt: Date(),
                            product: product
                        )
                        self.wishlistItems.append(wishlistItem)
                    }
                    
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error adding to wishlist: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFromWishlist(productId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                try await firebaseService.removeFromWishlist(userId: userId, productId: productId)
                
                await MainActor.run {
                    self.wishlistItems.removeAll { $0.productId == productId }
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error removing from wishlist: \(error.localizedDescription)")
            }
        }
    }
    
    func isInWishlist(productId: String) -> Bool {
        return wishlistItems.contains(where: { $0.productId == productId })
    }
}
