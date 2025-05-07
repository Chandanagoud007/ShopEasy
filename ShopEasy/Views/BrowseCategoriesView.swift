//
//  BrowseCategoriesView.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 05/05/25.
//

import SwiftUI

struct BrowseCategoriesView: View {
    private let categories = [
        "Electronics", "Clothing", "Home & Kitchen",
        "Beauty", "Sports", "Books", "Toys", "Grocery"
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(categories, id: \.self) { category in
                    NavigationLink(destination: CategoryProductsView(category: category)) {
                        CategoryCardView(category: category)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Categories")
    }
}

struct CategoryCardView: View {
    let category: String
    
    // Map categories to system images
    private var systemImage: String {
        switch category {
        case "Electronics": return "laptopcomputer"
        case "Clothing": return "tshirt"
        case "Home & Kitchen": return "house"
        case "Beauty": return "sparkles"
        case "Sports": return "sportscourt"
        case "Books": return "book"
        case "Toys": return "gamecontroller"
        case "Grocery": return "cart"
        default: return "tag"
        }
    }
    
    // Map categories to colors
    private var cardColor: Color {
        switch category {
        case "Electronics": return .blue
        case "Clothing": return .purple
        case "Home & Kitchen": return .orange
        case "Beauty": return .pink
        case "Sports": return .green
        case "Books": return .brown
        case "Toys": return .yellow
        case "Grocery": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Text(category)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [cardColor, cardColor.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: cardColor.opacity(0.4), radius: 5, x: 0, y: 3)
    }
}
