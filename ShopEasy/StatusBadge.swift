//
//  StatusBadge.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 06/05/25.
//

import SwiftUI

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch status.lowercased() {
        case "pending":
            return Color.orange
        case "shipped":
            return Color.blue
        case "delivered":
            return Color.green
        case "cancelled":
            return Color.red
        default:
            return Color.gray
        }
    }
}
