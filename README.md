# Offline-First Inventory Management System

A production-ready mobile inventory management application built with **Flutter** and **Node.js**, featuring offline-first architecture, real-time synchronization, and barcode scanning capabilities.

## 🎯 Features

### Flutter Mobile App

- ✅ Complete CRUD operations for products
- ✅ Offline-first architecture with Hive local database
- ✅ Barcode scanning using device camera
- ✅ Automatic background synchronization
- ✅ Clean architecture with GetX state management
- ✅ Sync status indicators
- ✅ Connectivity monitoring
- ✅ Material Design UI

### Node.js Backend

- ✅ RESTful API with Express.js
- ✅ MySQL database with Sequelize ORM
- ✅ Bulk sync endpoint
- ✅ Request validation
- ✅ Error handling & logging
- ✅ CORS enabled
- ✅ Soft delete support

## 🛠️ Tech Stack

**Frontend:**

- Flutter 3.x
- GetX (State Management)
- Hive (Local Database)
- mobile_scanner (Barcode Scanning)
- connectivity_plus (Network Detection)
- http (API Client)

**Backend:**

- Node.js
- Express.js
- MySQL
- Sequelize ORM
- Winston (Logging)
- Express Validator

## 📁 Project Structure

```
inventory_project/
├── flutter_app/          # Flutter mobile application
│   ├── lib/
│   │   ├── app/         # App configuration
│   │   ├── core/        # Constants, utilities, errors
│   │   ├── data/        # Models, datasources, repositories
│   │   ├── domain/      # Entities, repository interfaces
│   │   ├── presentation/# Controllers, pages, widgets
│   │   └── services/    # Sync, connectivity, barcode services
│   └── pubspec.yaml
│
└── backend/             # Node.js Express server
    ├── src/
    │   ├── config/      # Database configuration
    │   ├── controllers/ # Request handlers
    │   ├── models/      # Sequelize models
    │   ├── routes/      # API routes
    │   ├── services/    # Business logic
    │   ├── validators/  # Input validation
    │   └── middleware/  # Error handling
    ├── .env
    ├── package.json
    └── server.js
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.0+)
- **Node.js** (18+)
- **MySQL** (8.0+)
- **Android Studio / Xcode** (for running the app)

### Backend Setup

1. Navigate to backend directory:

```bash
cd backend
```

2. Install dependencies:

```bash
npm install
```

3. Configure database:
   - Open `.env` file
   - Update MySQL credentials:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=inventory_db
DB_USER=root
DB_PASSWORD=your_mysql_password
```

4. Create MySQL database:

```bash
mysql -u root -p
```

```sql
CREATE DATABASE inventory_db;
exit;
```

5. Start the server:

```bash
npm start
# or for development with auto-reload
npm run dev
```

The API will be available at `http://localhost:3000/api`

### Flutter App Setup

1. Navigate to flutter_app directory:

```bash
cd flutter_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Generate Hive adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Update API endpoint:
   - Open `lib/core/constants/api_constants.dart`
   - Set your backend URL:
     - For Android emulator: `http://10.0.2.2:3000/api`
     - For iOS simulator: `http://localhost:3000/api`
     - For real device: `http://YOUR_COMPUTER_IP:3000/api`

5. Run the app:

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device-id>
```

## 📱 Camera Permissions

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan barcodes</string>
```

## 🔄 How Sync Works

1. **Offline Operations**: All CRUD operations save to local Hive database first
2. **Sync Metadata**: Each record tracks `isSynced`, `syncAction`, and `serverId`
3. **Connectivity Monitoring**: App automatically detects internet connection
4. **Auto Sync**: When online, unsynced records are sent to server
5. **Idempotent Operations**: Server prevents duplicate records using `clientId`
6. **Soft Delete**: Deleted items are marked, not removed, to allow sync

## 🔍 API Endpoints

| Method | Endpoint             | Description           |
| ------ | -------------------- | --------------------- |
| POST   | `/api/products`      | Create product        |
| GET    | `/api/products`      | Get all products      |
| GET    | `/api/products/:id`  | Get product by ID     |
| PUT    | `/api/products/:id`  | Update product        |
| DELETE | `/api/products/:id`  | Delete product (soft) |
| POST   | `/api/products/sync` | Bulk sync products    |

## 🧪 Testing

### Test Backend API

```bash
# Health check
curl http://localhost:3000/health

# Create product
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "test-123",
    "name": "Test Product",
    "price": 10.99,
    "quantity": 5
  }'

# Get all products
curl http://localhost:3000/api/products
```

### Test Flutter App

- Run app on emulator
- Create product offline
- Turn off internet
- Create/Edit/Delete products
- Turn on internet
- Watch sync happen automatically

## 📝 Environment Variables

Create `.env` file in backend directory:

```env
NODE_ENV=development
PORT=3000

# MySQL Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=inventory_db
DB_USER=root
DB_PASSWORD=your_password

# Logging
LOG_LEVEL=info
```

## 🐛 Troubleshooting

### Backend Issues

**Database connection failed:**

- Verify MySQL is running
- Check credentials in `.env`
- Ensure database `inventory_db` exists

**Port already in use:**

- Change `PORT` in `.env` file
- Update Flutter API URL accordingly

### Flutter Issues

**Build runner fails:**

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Barcode scanner not working:**

- Check camera permissions
- Test on real device (camera doesn't work on emulator)

**Sync not happening:**

- Check API URL in `api_constants.dart`
- Verify backend is running
- Check internet connectivity
- View console logs for errors

## 📚 Project Highlights

This project demonstrates:

- ✅ Clean Architecture principles
- ✅ Offline-first mobile development
- ✅ State management with GetX
- ✅ Repository pattern
- ✅ Dependency injection
- ✅ RESTful API design
- ✅ Database synchronization strategies
- ✅ Error handling and validation
- ✅ Logging and monitoring

## 👨‍💻 Development Workflow

1. **MVP Phase**: Basic offline CRUD + API
2. **Sync Phase**: Implement sync engine
3. **Barcode Phase**: Add barcode scanning
4. **Polish Phase**: UI/UX improvements

## 🔒 Security Considerations

- ✅ Input validation on both client and server
- ✅ SQL injection protection (Sequelize)
- ✅ CORS configuration
- ✅ Helmet.js security headers
- ⚠️ TODO: Add authentication/authorization
- ⚠️ TODO: Encrypt sensitive data
- ⚠️ TODO: Add rate limiting

## 📈 Future Enhancements

- [ ] User authentication
- [ ] Product categories
- [ ] Image upload
- [ ] Export to CSV/PDF
- [ ] Search and filters
- [ ] Low stock alerts
- [ ] Multi-user support
- [ ] Real-time sync with WebSockets

## 📚 Documentation

Complete documentation for the project:

- **[SETUP.md](SETUP.md)** - Complete setup guide for both mobile app and backend
- **[MOBILE_APP.md](MOBILE_APP.md)** - Flutter app architecture, features, and development
- **[BACKEND.md](BACKEND.md)** - Node.js API documentation, endpoints, and database

## 🔒 Security & Configuration

This repository uses example configuration files to protect sensitive data:

- **Backend**: Copy `backend/.env.example` to `backend/.env` and update with your MySQL password
- **Flutter**: Copy `flutter_app/lib/core/constants/api_constants.dart.example` to `api_constants.dart` and update with your server IP

### ⚠️ Important Files

✅ **Safe to commit:**

- `.env.example` (template with placeholders)
- `api_constants.dart.example` (template with localhost)
- All source code and documentation

❌ **NEVER commit:**

- `.env` (contains database password)
- `api_constants.dart` (contains IP address)
- `node_modules/`, `build/`, logs

All sensitive files are already protected by `.gitignore`.

## �📄 License

MIT License - feel free to use for learning and portfolio projects

## 🤝 Contributing

This is a portfolio/learning project. Feel free to fork and customize!

---

**Built with ❤️ using Flutter and Node.js**
