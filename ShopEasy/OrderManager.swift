//
//  OrderManager.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 06/05/25.
//
import Foundation
import FirebaseAuth
import Combine

class OrderManager: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firebaseService = FirebaseService()
    private var cancellables = Set<AnyCancellable>()
    
    var pendingOrdersCount: Int {
        orders.filter { $0.status == .pending }.count
    }
    
    func fetchOrders() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        Task {
            do {
                let fetchedOrders = try await firebaseService.fetchOrders(userId: userId)
                
                // Load product details for each order
                var detailedOrders: [Order] = []
                
                for var order in fetchedOrders {
                    do {
                        let product = try await firebaseService.fetchProduct(id: order.productId)
                        order.product = product
                        
                        if let merchantOffer = product.merchants.first(where: { $0.merchantId == order.merchantId }) {
                            order.merchantOffer = merchantOffer
                        }
                        
                        detailedOrders.append(order)
                    } catch {
                        print("Error loading product details: \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    self.orders = detailedOrders
                    self.isLoading = false
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("Error fetching orders: \(error.localizedDescription)")
            }
        }
    }
    
    func placeOrder(cartItems: [CartItem], products: [Product]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                try await firebaseService.placeOrder(userId: userId, cartItems: cartItems, products: products)
                
                // Refresh orders after placing
                try await fetchOrders()
                
                await MainActor.run {
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error placing order: \(error.localizedDescription)")
            }
        }
    }
    
    func markAsDelivered(orderId: String, productId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                try await firebaseService.markOrderAsDelivered(userId: userId, orderId: orderId, productId: productId)
                
                await MainActor.run {
                    // Update local order status
                    if let index = self.orders.firstIndex(where: {
                        $0.orderId == orderId && $0.productId == productId
                    }) {
                        self.orders[index].status = .delivered
                        self.orders[index].isDelivered = true
                    }
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error marking order as delivered: \(error.localizedDescription)")
            }
        }
    }
}
