//
//  ProductsData.swift
//  ShopEasy
//
//  Created by Aasrith Mareddy on 06/05/25.
//

import Foundation

struct ProductsData {
    static let mockProducts: [Product] = [
        // Electronics
        Product(
            id: "p1",
            name: "Wireless Earbuds",
            description: "High-quality wireless earbuds with noise cancellation",
            price: 79.99,
            category: "Electronics",
            image: "headphones",
            rating: 4.5
        ),
        Product(
            id: "p2",
            name: "Smart Watch",
            description: "Track your fitness and stay connected with this smart watch",
            price: 199.99,
            category: "Electronics",
            image: "applewatch",
            rating: 4.3
        ),
        Product(
            id: "p3",
            name: "Bluetooth Speaker",
            description: "Portable speaker with amazing sound quality",
            price: 59.99,
            category: "Electronics",
            image: "hifispeaker.fill",
            rating: 4.2
        ),
        
        // Clothing
        Product(
            id: "p4",
            name: "Running Shoes",
            description: "Comfortable shoes for your daily run",
            price: 89.99,
            category: "Clothing",
            image: "beats.fit.pro",
            rating: 4.7
        ),
        Product(
            id: "p5",
            name: "Cotton T-Shirt",
            description: "Soft cotton t-shirt for everyday wear",
            price: 19.99,
            category: "Clothing",
            image: "tshirt",
            rating: 4.0
        ),
        
        // Home & Kitchen
        Product(
            id: "p6",
            name: "Coffee Maker",
            description: "Brew delicious coffee with this easy-to-use machine",
            price: 49.99,
            category: "Home & Kitchen",
            image: "cup.and.saucer.fill",
            rating: 4.8
        ),
        Product(
            id: "p7",
            name: "Blender",
            description: "Powerful blender for smoothies and more",
            price: 39.99,
            category: "Home & Kitchen",
            image: "flame",
            rating: 4.1
        ),
        
        // Beauty
        Product(
            id: "p8",
            name: "Face Serum",
            description: "Hydrating serum for all skin types",
            price: 24.99,
            category: "Beauty",
            image: "drop.fill",
            rating: 4.6
        ),
        
        // Sports
        Product(
            id: "p9",
            name: "Yoga Mat",
            description: "Non-slip yoga mat for your practice",
            price: 29.99,
            category: "Sports",
            image: "figure.yoga",
            rating: 4.4
        ),
        
        // Books
        Product(
            id: "p10",
            name: "Bestseller Novel",
            description: "The latest bestseller everyone is talking about",
            price: 14.99,
            category: "Books",
            image: "book.fill",
            rating: 4.9
        )
    ]
    
    static let mockMerchants: [Merchant] = [
        // Merchants for Wireless Earbuds
        Merchant(
            id: "m1",
            productId: "p1",
            name: "ElectroMax",
            price: 79.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            inStock: true,
            link: "https://example.com/electromax/earbuds"
        ),
        Merchant(
            id: "m2",
            productId: "p1",
            name: "TechGadgets",
            price: 74.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            inStock: true,
            link: "https://example.com/techgadgets/earbuds"
        ),
        Merchant(
            id: "m3",
            productId: "p1",
            name: "AudioWorld",
            price: 84.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            inStock: true,
            link: "https://example.com/audioworld/earbuds"
        ),
        
        // Merchants for Smart Watch
        Merchant(
            id: "m4",
            productId: "p2",
            name: "ElectroMax",
            price: 199.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            inStock: true,
            link: "https://example.com/electromax/smartwatch"
        ),
        Merchant(
            id: "m5",
            productId: "p2",
            name: "WatchStore",
            price: 189.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
            inStock: true,
            link: "https://example.com/watchstore/smartwatch"
        ),
        
        // Add more merchants for other products
        Merchant(
            id: "m6",
            productId: "p3",
            name: "SoundHub",
            price: 59.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            inStock: true,
            link: "https://example.com/soundhub/speaker"
        ),
        Merchant(
            id: "m7",
            productId: "p3",
            name: "AudioWorld",
            price: 54.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            inStock: true,
            link: "https://example.com/audioworld/speaker"
        ),
        
        // Add some merchants for other categories
        Merchant(
            id: "m8",
            productId: "p4",
            name: "SportsGear",
            price: 89.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            inStock: true,
            link: "https://example.com/sportsgear/runningshoes"
        ),
        Merchant(
            id: "m9",
            productId: "p4",
            name: "ShoeWarehouse",
            price: 94.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            inStock: true,
            link: "https://example.com/shoewarehouse/runningshoes"
        ),
        Merchant(
            id: "m10",
            productId: "p5",
            name: "FashionHub",
            price: 19.99,
            deliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            inStock: true,
            link: "https://example.com/fashionhub/tshirt"
        )
    ]
}
