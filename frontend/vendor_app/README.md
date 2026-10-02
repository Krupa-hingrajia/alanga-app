# 🛍️ ALANGA Vendor App (Seller Central)

Alanga Vendor Application ek modern, scalable multi-vendor e-commerce seller portal hai jo **Amazon Seller Central** aur **Meesho Supplier Panel** standards par design kiya gaya hai.

---

## 📌 Table of Contents
1. [Tech Stack & Architecture](#-tech-stack--architecture)
2. [Recently Added Core Modules](#-recently-added-core-modules)
   - [1. Multi-Image Gallery per Product](#1-multi-image-gallery-per-product)
   - [2. Product Variants (Size, Color & Attributes)](#2-product-variants-size-color--attributes)
   - [3. Global Live Inventory & Low Stock Alerts](#3-global-live-inventory--low-stock-alerts)
   - [4. Dashboard Modularization & Quick Actions](#4-dashboard-modularization--quick-actions)
3. [Project Directory & File Structure](#-project-directory--file-structure)
4. [Step-by-Step Testing Guide (Kese Test Karein)](#-step-by-step-testing-guide-kese-test-karein)
5. [Backend API Endpoint Mapping](#-backend-api-endpoint-mapping)

---

## 🚀 Tech Stack & Architecture

- **Framework:** Flutter (Material 3)
- **Architecture:** Clean Architecture + Repository Pattern
- **State Management:** `flutter_bloc`
- **Routing:** `go_router`
- **Networking:** `dio` (with Bearer Token Interceptor & Error Handlers)
- **Local Storage:** `flutter_secure_storage`
- **Image Handling:** Dynamic Base64 / Multipart / Disk Caching

---

## ✨ Recently Added Core Modules

### 1. Multi-Image Gallery per Product
- **Multi-Image Selection:** Vendor ek saath Camera ya Phone Gallery se maximum 10 images pick kar sakte hain.
- **Primary Image Badge:** Kisi bhi image ko 1-tap me **"Primary"** banaya ja sakta hai jo customer storefront par main picture banti hai.
- **Auto Thumbnail Sync:** Backend upload ke baad main `product.image` field ko primary image se automatically sync kar deta hai.
- **Interactive Carousel:** Product detail screen par swipeable image carousel, indicator (`1/N`), thumbnail selector strip, aur variant-specific images view available hai.
- **Files:**
  - `lib/features/products/presentation/widgets/product_images_section.dart`
  - `lib/features/products/presentation/screens/product_detail_screen.dart`
  - `lib/features/products/data/models/product_image_model.dart`

---

### 2. Product Variants (Size, Color & Attributes)
- **Dynamic Variant Matrix:** Vendor har product ke multiple variations define kar sakte hain:
  - **Size:** S, M, L, XL, XXL, etc.
  - **Color:** Red, Blue, Black, White, etc.
  - **Attributes:** Storage, Material, Style, Weight, etc.
  - **SKU & Price:** Har variant ka apna unique SKU code, selling price override, aur stock count.
- **Direct Management in Detail Screen:**
  - Product Details screen ke **"Variants & Attributes"** card me direct **"+ Add Variant"** button.
  - Variant detail modal me **"Edit Variant"** aur **"Delete Variant"** actions.
- **Files:**
  - `lib/features/products/presentation/widgets/add_edit_variant_bottom_sheet.dart`
  - `lib/features/products/presentation/widgets/product_variants_section.dart`
  - `lib/features/products/presentation/widgets/product_variant_card.dart`
  - `lib/features/products/data/models/product_variant_model.dart`
  - `lib/features/products/data/models/attribute_model.dart`

---

### 3. Global Live Inventory & Low Stock Alerts
- **Dedicated Route:** `/inventory`
- **Hero Metrics:**
  - 🔴 **Out of Stock:** 0 units
  - 🟡 **Low Stock Alert:** 1 se 5 units
  - 🟢 **In Stock:** 5+ units
- **Instant Stock Controls:**
  - `[-]` and `[+]` quick step buttons (Optimistic UI update with rollback on failure).
  - Quick add shortcuts: `+5` aur `+10` chips.
  - Tap-to-edit exact units dialog with preset shortcuts (`+10`, `+25`, `+50`, `+100`).
  - Variant stock drawer navigation button (`/products/inventory`).
- **Dashboard Low Stock Banner:** Dashboard screen par critical low stock products detect hone par automatic dynamic alert banner show hota hai jisme direct **"Manage"** button routing provide karta hai.
- **Files:**
  - `lib/features/inventory/presentation/screens/global_inventory_screen.dart`
  - `lib/features/inventory/presentation/screens/product_inventory_screen.dart`

---

### 4. Dashboard Modularization & Quick Actions
3,380+ lines ki monolithic `dashboard_screen.dart` file ko 4 modular widgets me break kiya gaya hai:
1. **`dashboard_quick_add_modal.dart`:** Quick action drawer for Product, Live Inventory, Category, Sub Category, and Brand.
2. **`dashboard_master_data_sheets.dart`:** Marketplace Categories, Sub Categories, aur Brands explore sheets with search & filter.
3. **`dashboard_alerts_tab.dart`:** Vendor operational alerts aur notifications tab.
4. **`dashboard_profile_tab.dart`:** Store profile, verified KYC badge, settings, support aur secure logout modal.
- **Files:**
  - `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
  - `lib/features/dashboard/presentation/widgets/dashboard_quick_add_modal.dart`
  - `lib/features/dashboard/presentation/widgets/dashboard_master_data_sheets.dart`
  - `lib/features/dashboard/presentation/widgets/dashboard_alerts_tab.dart`
  - `lib/features/dashboard/presentation/widgets/dashboard_profile_tab.dart`

---

## 📁 Project Directory & File Structure

```text
lib/
├── core/
│   ├── constants/app_colors.dart
│   ├── network/api_service.dart
│   └── widgets/custom_image_view.dart
├── features/
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── screens/dashboard_screen.dart
│   │       └── widgets/
│   │           ├── dashboard_quick_add_modal.dart      <-- [NEW] Quick actions
│   │           ├── dashboard_master_data_sheets.dart   <-- [NEW] Categories/Brands sheets
│   │           ├── dashboard_alerts_tab.dart           <-- [NEW] Alerts tab
│   │           └── dashboard_profile_tab.dart          <-- [NEW] Profile & KYC tab
│   ├── inventory/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── global_inventory_screen.dart        <-- [NEW] Live stock dashboard
│   │           └── product_inventory_screen.dart       <-- Variant-level adjustments
│   ├── products/
│   │   ├── data/models/
│   │   │   ├── product_model.dart                     <-- [UPDATED] copyWith & primaryImageUrl
│   │   │   ├── product_image_model.dart
│   │   │   ├── product_variant_model.dart
│   │   │   └── attribute_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── add_edit_product_screen.dart        <-- Multi-image + variants integration
│   │       │   └── product_detail_screen.dart          <-- Carousel + variant actions
│   │       └── widgets/
│   │           ├── product_images_section.dart         <-- Multi-picker (camera/gallery)
│   │           ├── product_variants_section.dart       <-- Variants table & list
│   │           └── add_edit_variant_bottom_sheet.dart  <-- Variant size/color modal
└── routes/
    └── app_router.dart                                 <-- Registered /inventory route
```

---

## 🧪 Step-by-Step Testing Guide (Kese Test Karein)

### Step 1: Backend Start Karein
Terminal open karein aur backend directory me check karein:
```bash
cd "/Users/apple/Desktop/Alanga/Alanga App/backend"
npm run start:dev
```
*Backend port 3000 par live hona chahiye.*

### Step 2: Vendor App Launch Karein
Dusre terminal window me:
```bash
cd "/Users/apple/Desktop/Alanga/Alanga App/frontend/vendor_app"
flutter run
```

---

### 🔍 Test Scenario 1: Multi-Image Product Gallery Test
1. App open karke Vendor account se login karein.
2. Bottom bar ya FAB (+) par tap karke **"Add Product"** par jayein.
3. Form fill karein: Name, MRP, Selling Price, Category, Brand, etc.
4. **Step 5 (Product Images)** par scroll karein:
   - **"Add Images"** button tap karein -> **Gallery** ya **Camera** select karein.
   - 2 ya 3 images choose karein.
   - Preview grid me images display hongi.
   - Kisi ek image par **"Set as Primary"** ya Star icon tap karein -> Use par green **"PRIMARY"** badge lag jayega.
5. **"Submit Product"** button dabayein.
6. Product create hone ke baad us product par tap karke **Product Detail Screen** open karein:
   - Swipe karein: Top image carousel me swipeable images aur indicator (`1/3`, `2/3`, `3/3`) dikhega.
   - Bottom thumbnail strip me tap karke image switch karke dekhein.

---

### 🔍 Test Scenario 2: Product Variants (Size & Color) Test
1. **Product Detail Screen** par scroll down karein:
   - **"Variants & Attributes"** card dekhein.
   - Header me direct **"+ Add Variant"** button tap karein (ya create screen par Step 6).
2. **Variant Sheet khulegi:**
   - **Size:** Chip select karein (e.g. `M`, `L`, ya `XL`).
   - **Color:** Chip select karein (e.g. `Red`, `Black`, etc.).
   - **SKU Code:** Auto-fill hoga ya customize karein (e.g. `TSHIRT-BLK-L`).
   - **Price & Stock:** Selling price aur warehouse stock units enter karein.
   - **Save Variant** tap karein.
3. Variant list update ho jayegi aur card me naya variant show hoga.
4. Us variant item par tap karein:
   - Variant details popup khulega with full SKU, attributes, aur price.
   - Popup ke bottom me **"Edit Variant"** tap karke details modify karein.
   - Delete icon tap karke confirmation ke saath delete test karein.

---

### 🔍 Test Scenario 3: Live Global Inventory & Low Stock Alerts Test
1. **Dashboard par jayein:**
   - Quick Actions Reel me **"Inventory"** icon par tap karein, ya FAB (+) tap karke **"Live Inventory"** choose karein.
2. **Global Inventory Screen khulegi:**
   - Top Summary Cards check karein:
     - 🔴 Out of Stock count
     - 🟡 Low Stock count (≤ 5 units)
     - 🟢 In Stock count (> 5 units)
   - Filter chips tap karein: `Low Stock`, `Out of Stock`, `In Stock` — list filter hogi.
   - Search bar me kisi product ka naam ya SKU type karke instant filter check karein.
3. **1-Tap Stock Update Test:**
   - Kisi item ka `[+]` button dabayein -> Stock turant +1 ho jayega.
   - `[-]` button dabayein -> Stock turant -1 ho jayega.
   - `+5` ya `+10` chip dabayein -> Stock turant increment hoga.
   - Middle me **Units box** par tap karein -> **"Set Exact Stock"** dialog khulega. Yahan koi bhi exact number (e.g. `25` ya `100`) enter karke Save karein.
4. **Low Stock Alert Banner Test:**
   - Kisi product ka stock kam karke `2` ya `0` kar dein.
   - Back karke Dashboard par aayein -> Dashboard top par amber/red alert banner dikhega:
     *⚠️ "Action Needed: 1 Out of Stock • 1 Low Stock Items"*
   - Banner ke **"Manage"** button par tap karein -> Seedha Inventory screen par redirect ho jayenge!

---

### 🔍 Test Scenario 4: Modular Dashboard & Quick Actions Test
1. Dashboard bottom navigation bar me:
   - **Alerts tab** (bell icon) tap karein -> System notifications aur seller alerts load honge.
   - **Profile tab** (person icon) tap karein -> Vendor details, verified seller badge, store KYC status, Settings, Support aur **Logout** button check karein.
2. Floating Action Button (+) tap karein:
   - Naya **Quick Management Actions** modal khulega:
     - *Add Product*
     - *Live Inventory*
     - *Add Category*
     - *Add Sub Category*
     - *Register Brand*
   - Kisi bhi action par tap karke verify karein ki respective screen properly khul rahi hai.

---

## 🌐 Backend API Endpoint Mapping

| Feature | HTTP Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **Product Images** | `POST` | `/vendor/products/:productId/images` | Upload up to 10 images (Multipart FormData) |
| **Get Images** | `GET` | `/vendor/products/:productId/images` | Fetch product images gallery |
| **Set Primary** | `PUT` | `/vendor/products/:productId/images/:imageId/primary` | Set primary cover thumbnail |
| **Delete Image** | `DELETE`| `/vendor/products/:productId/images/:imageId` | Remove image from gallery |
| **Create Variant** | `POST` | `/vendor/products/:productId/variants` | Add size/color SKU variation |
| **Update Variant** | `PUT` | `/vendor/products/:productId/variants/:variantId` | Update variant price/stock |
| **Delete Variant** | `DELETE`| `/vendor/products/:productId/variants/:variantId` | Delete variant |
| **Stock Update** | `PUT` | `/vendor/products/:id` | Update master stock count |
| **Variant Stock** | `PUT` | `/vendor/products/:productId/inventory` | Adjust variant inventory count |
| **Attributes** | `GET` | `/master-data/attributes` | Fetch available dynamic attributes |

---

## ✅ Quality & Code Health Verification

```bash
# Frontend Code Analysis
cd frontend/vendor_app
flutter analyze
# Output: 0 errors (clean compilation)

# Backend Build Check
cd backend
npm run build
# Output: NestJS build passed with 0 errors
```
