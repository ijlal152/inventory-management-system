# 📱 Mobile App Documentation

Flutter-based offline-first inventory management mobile application.

## 🎯 Overview

The mobile app is built with Flutter and follows **Clean Architecture** principles, ensuring separation of concerns, testability, and maintainability. It features offline-first capabilities with automatic background synchronization.

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── domain/              # Business Logic Layer (Pure Dart)
│   ├── entities/        # Business objects (Product)
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business use cases
├── data/                # Data Layer
│   ├── models/          # Data models (DTO)
│   ├── repositories/    # Repository implementations
│   └── datasources/     # Local (Hive) & Remote (API)
└── presentation/        # UI Layer
    ├── pages/           # Screen widgets
    ├── controllers/     # GetX state management
    └── widgets/         # Reusable components
```

### Key Components

**Domain Layer (Business Logic)**

- `Product` entity - Pure business object
- `ProductRepository` interface - Contract for data operations
- Use cases:
  - `GetAllProductsUseCase` - Fetch all products
  - `CreateProductUseCase` - Create new product
  - `UpdateProductUseCase` - Update existing product
  - `DeleteProductUseCase` - Delete product
  - `SyncProductsUseCase` - Synchronize with server

**Data Layer**

- `ProductModel` - Data transfer object with JSON serialization
- `ProductRepositoryImpl` - Implements repository interface
- `LocalDataSource` - Hive database operations
- `RemoteDataSource` - API calls to backend
- Mappers - Convert between entities and models

**Presentation Layer**

- `ProductController` - Unified controller for all product operations
- `ProductListPage` - Display products with sync status
- `ProductFormPage` - Create/edit products
- Background sync service with WorkManager

## ✨ Features

### Offline-First Architecture

The app works seamlessly without internet connection:

1. **Local-First Storage**
   - All data saved to Hive (local database) immediately
   - No waiting for server response
   - Instant UI updates

2. **Sync Status Tracking**
   - Products marked as "unsynced" after create/update
   - Visual indicators:
     - 🟠 Orange background = Not synced
     - 🏷️ "LOCAL" badge = Awaiting sync
     - ⚪ White background = Successfully synced

3. **Automatic Background Sync**
   - **Foreground**: Every 2 minutes (Timer)
   - **Background**: Every 15 minutes (WorkManager)
   - **On Resume**: Immediate sync check
   - No manual intervention needed

### Barcode Scanning

- Uses device camera to scan barcodes
- Supports multiple barcode formats (EAN, UPC, QR, etc.)
- Auto-fills barcode field in product form
- Fast and accurate scanning

### Product Management

**Create Product**

1. Tap "+" button
2. Fill details (name, quantity, price)
3. Optionally scan barcode
4. Save → Stored locally → Syncs in 2-3 minutes

**Update Product**

1. Tap product from list
2. Modify fields
3. Save → Updated locally → Syncs in background

**Delete Product**

1. Swipe left on product
2. Confirm deletion
3. Removed locally → Synced with server

**Search Products**

- Real-time search as you type
- Searches name and barcode
- Works offline (searches local database)

### Connectivity Monitoring

- Automatic network detection
- Shows connectivity status in UI
- Adapts sync behavior based on connection
- Queues operations when offline

## 🔧 Technical Stack

### Dependencies

```yaml
dependencies:
  flutter: sdk: flutter

  # State Management
  get: ^4.6.6                    # GetX for state & navigation

  # Local Database
  hive: ^2.2.3                   # NoSQL local storage
  hive_flutter: ^1.1.0           # Hive initialization

  # Networking
  http: ^1.1.0                   # HTTP client
  connectivity_plus: ^5.0.2      # Network monitoring

  # Barcode
  mobile_scanner: ^3.5.7         # Camera barcode scanning

  # Background Tasks
  workmanager: ^0.9.0+3          # Background sync (iOS/Android)

  # Utilities
  intl: ^0.18.1                  # Date formatting
  path_provider: ^2.1.1          # File paths

dev_dependencies:
  hive_generator: ^2.0.1         # Code generation
  build_runner: ^2.4.6           # Build tools
```

### State Management (GetX)

**Why GetX?**

- Lightweight and fast
- Reactive programming
- Dependency injection
- Route management
- No context needed

**Usage Example:**

```dart
class ProductController extends GetxController {
  final products = <Product>[].obs;

  Future<void> loadProducts() async {
    final result = await getAllProductsUseCase();
    products.value = result;
  }
}

// In UI
Obx(() => ListView.builder(
  itemCount: controller.products.length,
  itemBuilder: (context, index) {
    final product = controller.products[index];
    return ProductTile(product);
  },
))
```

### Local Database (Hive)

**Why Hive?**

- Fast (pure Dart, no native bridge)
- Lightweight (no SQL overhead)
- Strongly typed
- Encryption support
- Cross-platform

**Storage Structure:**

```dart
@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0) int? id;
  @HiveField(1) String barcode;
  @HiveField(2) String name;
  @HiveField(3) int quantity;
  @HiveField(4) double price;
  @HiveField(5) List<String>? images;
  @HiveField(6) bool isSynced;
  @HiveField(7) int? serverId;
}
```

**Boxes:**

- `productsBox` - Stores all products
- Fast CRUD operations
- Indexed queries for search

### Background Sync (WorkManager)

**Platform Support:**

- ✅ Android - Periodic background tasks
- ✅ iOS - Background fetch

**Configuration:**

```dart
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await syncProducts(); // Run use case
    return Future.value(true);
  });
}

// Initialize
Workmanager().initialize(callbackDispatcher);

// Schedule periodic sync (15 min minimum on Android)
Workmanager().registerPeriodicTask(
  "product-sync",
  "syncProducts",
  frequency: Duration(minutes: 15),
);
```

**Foreground Sync:**

```dart
Timer.periodic(Duration(minutes: 2), (_) {
  if (connected) {
    syncProducts();
  }
});
```

## 📱 User Interface

### Screens

**1. Product List Page**

- Shows all products (synced and unsynced)
- Visual sync indicators
- Pull-to-refresh
- Search bar
- Swipe-to-delete
- Floating action button to add product

**2. Product Form Page**

- Name input
- Barcode input with scan button
- Quantity input (number)
- Price input (decimal)
- Save button
- Barcode scanner integration

**3. Barcode Scanner Page**

- Full-screen camera view
- Real-time barcode detection
- Auto-close on successful scan
- Manual cancel option

### Visual Design

**Material Design 3**

- Modern, clean interface
- Consistent spacing and typography
- Intuitive icons
- Responsive layouts

**Color Scheme**

- Primary: Blue (`Colors.blue`)
- Unsynced: Orange (`Colors.orange[100]`)
- Synced: White
- Delete: Red
- Success: Green

**Typography**

- Headings: Bold, larger font
- Body: Regular weight
- Prices: Formatted with currency

## 🔄 Sync Mechanism

### How Sync Works

**1. Create/Update Operation**

```
User Action → Save to Hive → Mark isSynced=false → Show "LOCAL" badge
              ↓
         Wait 2-3 minutes
              ↓
   Background Timer triggers → Check connectivity → Sync with API
              ↓
   Success → Update isSynced=true → Remove badge → Update UI
```

**2. Server Conflict Resolution**

- Barcode uniqueness enforced on server
- If conflict, show error to user
- Local data preserved until resolved

**3. Delete Operation**

- Immediate local delete
- Background sync sends DELETE to API
- Server removes record

### Sync Flow Diagram

```
┌─────────────┐
│ User Input  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Save to Hive    │ ← Immediate (offline works)
│ isSynced=false  │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Show in UI      │ ← Orange background + LOCAL badge
│ with indicator  │
└──────┬──────────┘
       │
       ▼ (2-3 minutes later)
┌─────────────────┐
│ Background Sync │ ← Timer or WorkManager
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Check Network   │
└──────┬──────────┘
       │
   ┌───┴───┐
   │       │
   ▼       ▼
Online   Offline
   │       │
   │       └──► Retry later
   │
   ▼
┌─────────────────┐
│ Sync with API   │
└──────┬──────────┘
       │
   ┌───┴────┐
   │        │
   ▼        ▼
Success   Error
   │        │
   │        └──► Show error, keep LOCAL
   │
   ▼
┌─────────────────┐
│ Update Hive     │
│ isSynced=true   │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Update UI       │ ← White background, no badge
└─────────────────┘
```

## 🧪 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart

# Code coverage
flutter test --coverage
```

### Test Structure

```
test/
├── domain/
│   ├── entities/
│   └── usecases/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
└── presentation/
    └── controllers/
```

## 🚀 Running the App

### For Android Emulator

```bash
cd flutter_app
flutter pub get
flutter run
```

API will connect to: `http://10.0.2.2:3000/api`

### For iOS Simulator

```bash
cd flutter_app
flutter pub get
flutter run -d iPhone
```

API will connect to: `http://localhost:3000/api`

### For Real Device

```bash
cd flutter_app
flutter pub get
flutter run
```

Make sure to update `api_constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
```

## 🐛 Troubleshooting

### App Not Syncing

**Check:**

1. Backend server is running (`http://YOUR_IP:3000/health`)
2. Device has internet connection
3. API URL is correct in `api_constants.dart`
4. Firewall allows port 3000

**Debug:**

```bash
# Check Flutter logs
flutter logs

# Watch network requests
# Enable debug mode in RemoteDataSource
```

### Barcode Scanner Not Working

**Android:**

- Grant camera permission in settings
- Check `AndroidManifest.xml` has camera permission

**iOS:**

- Grant camera permission in settings
- Check `Info.plist` has NSCameraUsageDescription

### Build Errors

```bash
# Clean build
flutter clean
rm -rf .dart_tool/
flutter pub get

# Rebuild
flutter run
```

### Hive Errors

```bash
# Delete local database
flutter clean

# Regenerate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 📱 Supported Platforms

- ✅ **Android** - API 21+ (Android 5.0+)
- ✅ **iOS** - iOS 12.0+
- ⏳ **Web** - Planned (Hive has web support)
- ⏳ **Desktop** - Planned (Windows, macOS, Linux)

## 🔐 Security Considerations

- No authentication implemented (add JWT/OAuth for production)
- No data encryption (Hive supports encryption)
- API key should be secured (use environment variables)
- HTTPS recommended for production

## 📦 Build for Production

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
# Then archive in Xcode
```

## 🎯 Future Enhancements

- [ ] User authentication
- [ ] Product categories
- [ ] Image upload
- [ ] Batch operations
- [ ] Export/import data
- [ ] Offline photo capture
- [ ] Dark mode
- [ ] Localization (multi-language)
- [ ] Analytics
- [ ] Push notifications

---

For backend details, see [BACKEND.md](BACKEND.md)  
For setup instructions, see [SETUP.md](SETUP.md)
