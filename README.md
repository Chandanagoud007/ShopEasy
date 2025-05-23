# ShopEasy
ShopEasy is an iOS shopping aggregator app that helps users search, compare, and buy products from various e-commerce platforms in one place. It offers a clean UI, fast product lookup, and Google-based login. Products are currently served via mock data stored in Firebase, which can later be replaced with real data using web scraping or APIs.


---


## Views Breakdown

### 1. **Login View**
- Functionality: Google Sign-In integration.
- Purpose: Allows users to log in securely before accessing the app.
- Access Control: Admin vs User roles handled here.

### 2. **Home / Browse View**
- Functionality: Displays categorized product listings.
- Purpose: Serves as the main entry point for browsing.
- Component: HomePageView.

### 3. **Search View**
- Functionality: Displays a list of matching products from  mock data stored in Firebase.
                 Shows product name, image, price, and source.
- Purpose: Helps users quickly compare products across sites.

### 4. **Product Detail View**
- Functionality: Displays full details, vendor info, and “Add to Cart” option.
- Purpose: Allows users to make informed decisions before purchasing.

### 5. **Cart View**
- Functionality: View and manage cart items, clear cart, proceed to checkout.
- Purpose: Enables users to keep track of items they’re interested in.

### 6. **Admin Panel**
- Functionality: Allows admin users to upload or update product data in Firebase.
                 Access is restricted to a specific admin email.
- Built for easy transition to real product data in the future.

---

## App Flow

1. **Login** using Google.
2. Land on **Home Page** to browse products.
3. Use the **Search Bar** to filter by keywords.
4. Tap any product to view **details** and **add to cart**.
5. Navigate to **Cart**, where you can **clear** or **buy** items.
6. **Admin** can access the panel to manage product data in Firebase.

---

##  Tech Stack

- **Language**: Swift (iOS)
- **UI Framework**: SwiftUI
- **Auth & DB**: Firebase (Google Auth + Firestore)
- **Architecture**: MVVM with Manager/Service layer
- **Tools**: Xcode, Firebase Console

---
