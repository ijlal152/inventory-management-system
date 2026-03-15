# ⚙️ Setup Guide

Complete configuration guide for both mobile app and backend.

## 📋 Prerequisites

Before you begin, ensure you have installed:

- **Flutter SDK** (3.0 or higher)
  - [Install Flutter](https://flutter.dev/docs/get-started/install)
  - Verify: `flutter --version`

- **Node.js** (16 or higher)
  - [Install Node.js](https://nodejs.org/)
  - Verify: `node --version` and `npm --version`

- **MySQL** (8.0 or 9.0)
  - macOS: `brew install mysql`
  - Ubuntu: `sudo apt install mysql-server`
  - Windows: [Download MySQL](https://dev.mysql.com/downloads/installer/)
  - Verify: `mysql --version`

- **IDE** (Optional but recommended)
  - [VS Code](https://code.visualstudio.com/) with Flutter & Dart extensions
  - [Android Studio](https://developer.android.com/studio)

- **Device/Emulator**
  - Android Emulator (via Android Studio)
  - iOS Simulator (macOS only, via Xcode)
  - Physical device (USB debugging enabled)

## 🚀 Quick Setup (5 Minutes)

### Step 1: Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/inventory-management-system.git
cd inventory-management-system
```

### Step 2: Configure Backend

```bash
# Navigate to backend
cd backend

# Copy environment template
cp .env.example .env

# Edit .env file with your MySQL password
nano .env  # or use any text editor
```

Update the password in `.env`:

```env
DB_PASSWORD=your_mysql_password_here
```

```bash
# Install dependencies
npm install

# Start server
npm start
```

You should see:

```
Server running on http://0.0.0.0:3000
Database synced successfully
```

### Step 3: Configure Flutter App

Open a **new terminal** (keep backend running):

```bash
# Navigate to Flutter app
cd flutter_app

# Copy API configuration template
cp lib/core/constants/api_constants.dart.example lib/core/constants/api_constants.dart
```

**Edit `api_constants.dart`** based on your device:

```dart
class ApiConstants {
  // For Android Emulator:
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // For iOS Simulator:
  // static const String baseUrl = 'http://localhost:3000/api';

  // For Real Device (same WiFi as your computer):
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
}
```

```bash
# Install dependencies
flutter pub get

# Run app
flutter run
```

**Done!** 🎉 The app should launch and connect to your backend.

## 📱 Device-Specific Configuration

### Android Emulator

1. **Start Android Emulator** (via Android Studio or command line)
2. **API Configuration:**
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000/api';
   ```
3. **Run:**
   ```bash
   flutter run
   ```

**Why 10.0.2.2?**  
Android emulator maps `10.0.2.2` to the host machine's `localhost`.

### iOS Simulator

1. **Start iOS Simulator** (macOS only)
   ```bash
   open -a Simulator
   ```
2. **API Configuration:**
   ```dart
   static const String baseUrl = 'http://localhost:3000/api';
   ```
3. **Run:**
   ```bash
   flutter run -d iPhone
   ```

### Real Device (Android/iOS)

1. **Enable USB Debugging**
   - Android: Settings → Developer Options → USB Debugging
   - iOS: Trust computer when prompted

2. **Connect device to same WiFi as your computer**

3. **Find your computer's IP address:**

   **macOS:**

   ```bash
   ipconfig getifaddr en0
   # Example output: 192.168.1.100
   ```

   **Linux:**

   ```bash
   hostname -I | awk '{print $1}'
   # Example output: 192.168.1.100
   ```

   **Windows:**

   ```cmd
   ipconfig
   # Look for "IPv4 Address" under your active network adapter
   ```

4. **Update API Configuration:**

   ```dart
   static const String baseUrl = 'http://YOUR_IP_HERE:3000/api';
   // Example: 'http://192.168.1.100:3000/api'
   ```

5. **Ensure backend binds to 0.0.0.0** (already configured in server.js):

   ```javascript
   app.listen(3000, "0.0.0.0", () => {
     console.log("Server running on http://0.0.0.0:3000");
   });
   ```

6. **Allow firewall** (if needed):

   ```bash
   # macOS
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add node

   # Linux
   sudo ufw allow 3000/tcp
   ```

7. **Run app:**
   ```bash
   flutter run
   ```

## 🗄️ MySQL Setup

### Option 1: Automatic (Recommended)

The database is created automatically when you start the backend for the first time. Just make sure MySQL is running and credentials in `.env` are correct.

### Option 2: Manual Setup

If you prefer to create the database manually:

```bash
# Login to MySQL
mysql -u root -p

# Create database
CREATE DATABASE inventory_db;

# Verify
SHOW DATABASES;

# Exit
EXIT;
```

Then start the backend - tables will be created automatically.

### Option 3: Import Schema

If you have a SQL dump:

```bash
mysql -u root -p inventory_db < backend/database/schema.sql
```

### Common MySQL Commands

```bash
# Start MySQL (macOS)
brew services start mysql

# Start MySQL (Linux)
sudo systemctl start mysql

# Stop MySQL (macOS)
brew services stop mysql

# Stop MySQL (Linux)
sudo systemctl stop mysql

# Check MySQL status
brew services list | grep mysql  # macOS
sudo systemctl status mysql      # Linux

# Login to MySQL
mysql -u root -p

# Reset root password (if forgotten)
# MySQL 8.0+:
mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'newpassword';
FLUSH PRIVILEGES;
```

## 🧪 Verify Installation

### Test Backend

```bash
# Health check
curl http://localhost:3000/health

# Should return:
# {"status":"ok","timestamp":"...","uptime":123}

# Get products (empty initially)
curl http://localhost:3000/api/products

# Should return:
# {"success":true,"count":0,"data":[]}
```

### Test Flutter App

1. **Launch app** on device/emulator
2. **Check connection** - You should see empty product list
3. **Create a product:**
   - Tap "+" button
   - Fill details (name, barcode, quantity, price)
   - Save
4. **Verify:**
   - Product appears with "LOCAL" badge (orange background)
   - Wait 2-3 minutes
   - Badge should disappear (synced successfully)

### Test Database

```bash
# Login to MySQL
mysql -u root -p

# Use database
USE inventory_db;

# Check tables
SHOW TABLES;

# Should show:
# +------------------------+
# | Tables_in_inventory_db |
# +------------------------+
# | products               |
# +------------------------+

# View products
SELECT * FROM products;

# Exit
EXIT;
```

## 🐛 Troubleshooting

### Backend Issues

#### "Cannot connect to MySQL"

**Solution:**

```bash
# Check MySQL is running
mysql --version
brew services list | grep mysql  # macOS
sudo systemctl status mysql      # Linux

# Start MySQL if stopped
brew services start mysql        # macOS
sudo systemctl start mysql       # Linux

# Test connection
mysql -u root -p

# Check .env file has correct password
cat backend/.env | grep DB_PASSWORD
```

#### "Port 3000 already in use"

**Solution:**

```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 PID_NUMBER

# Or use different port in .env
PORT=3001
```

#### "Module not found"

**Solution:**

```bash
cd backend
rm -rf node_modules
npm install
```

### Flutter App Issues

#### "Connection refused" or "Network error"

**Checklist:**

1. ✅ Backend is running (`curl http://localhost:3000/health`)
2. ✅ Correct IP in `api_constants.dart`
3. ✅ Device/emulator has internet connection
4. ✅ Firewall allows port 3000
5. ✅ Device on same WiFi (for real devices)

**Test connection from device:**

- Open browser on device
- Navigate to `http://YOUR_IP:3000/health`
- Should see JSON response

#### "Camera permission denied"

**Android:**

```xml
<!-- Check AndroidManifest.xml has: -->
<uses-permission android:name="android.permission.CAMERA" />
```

Then: Settings → Apps → Your App → Permissions → Camera → Allow

**iOS:**

```xml
<!-- Check Info.plist has: -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan barcodes</string>
```

Then: Settings → Your App → Camera → Allow

#### "Hive error" or "Database error"

**Solution:**

```bash
# Clear app data
flutter clean
rm -rf .dart_tool
flutter pub get

# Uninstall app from device
flutter run --uninstall-first

# Rebuild
flutter run
```

#### Build errors with workmanager

**Solution:**

```bash
# Ensure correct version in pubspec.yaml
workmanager: ^0.9.0+3

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Network Troubleshooting

#### Find Your Computer's IP

```bash
# macOS
ipconfig getifaddr en0

# Linux
hostname -I | awk '{print $1}'

# Windows (PowerShell)
(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi").IPAddress
```

#### Test API from Device Browser

On your device, open browser and visit:

```
http://YOUR_COMPUTER_IP:3000/health
```

If this works, the problem is in Flutter app configuration. If it doesn't work:

1. Check firewall settings
2. Ensure both devices on same WiFi
3. Check backend is bound to `0.0.0.0` not `localhost`

#### Check Firewall

**macOS:**

```bash
# Check firewall status
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Allow Node.js
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node
```

**Linux:**

```bash
# Check firewall status
sudo ufw status

# Allow port 3000
sudo ufw allow 3000/tcp
```

**Windows:**

```
Control Panel → Windows Defender Firewall → Allow an app → Add Node.js
```

## 🔧 Advanced Configuration

### Change Server Port

**Backend (.env):**

```env
PORT=3001
```

**Flutter (api_constants.dart):**

```dart
static const String baseUrl = 'http://YOUR_IP:3001/api';
```

### Multiple Environments

**Backend:**

Create `.env.development`, `.env.production`:

```bash
# Run with specific env
NODE_ENV=production npm start
```

**Flutter:**

Create multiple config files:

```dart
// lib/config/dev_config.dart
static const String baseUrl = 'http://localhost:3000/api';

// lib/config/prod_config.dart
static const String baseUrl = 'https://api.yourapp.com/api';
```

### Database Configuration

**Change database name (.env):**

```env
DB_NAME=my_inventory_db
```

**Enable SQL logging (database.js):**

```javascript
logging: console.log; // Shows all SQL queries
```

### Sync Timing

**Change foreground sync interval (product_controller.dart):**

```dart
Timer.periodic(Duration(minutes: 5), (_) {  // Changed from 2 to 5
  if (connected) syncProducts();
});
```

**Change background sync interval (background_sync_service.dart):**

```dart
// Note: Android minimum is 15 minutes
Workmanager().registerPeriodicTask(
  "product-sync",
  "syncProducts",
  frequency: Duration(minutes: 30),  // Changed from 15 to 30
);
```

## 📚 Development Workflow

### Recommended Workflow

**Terminal 1 - Backend:**

```bash
cd backend
npm start
# Keep running
```

**Terminal 2 - Flutter:**

```bash
cd flutter_app
flutter run
# Keep running with hot reload
```

**Terminal 3 - Logs:**

```bash
# Watch backend logs
tail -f backend/logs/combined.log

# Or watch MySQL queries
mysql -u root -p inventory_db -e "SHOW PROCESSLIST;" --watch=1
```

### Hot Reload (Flutter)

While app is running:

- Press `r` - Hot reload (fast, preserves state)
- Press `R` - Hot restart (slower, resets state)
- Press `q` - Quit

### Database Reset

**Clear all products:**

```bash
mysql -u root -p inventory_db -e "TRUNCATE TABLE products;"
```

**Reset entire database:**

```bash
mysql -u root -p inventory_db -e "DROP DATABASE inventory_db; CREATE DATABASE inventory_db;"
cd backend
npm start  # Will recreate tables
```

## 🎯 Next Steps

✅ **Setup Complete!** Here's what to do next:

1. **Explore the app** - Create, update, delete products
2. **Test offline mode** - Turn off WiFi, create products, turn WiFi back on
3. **Test sync** - Watch products sync automatically after 2-3 minutes
4. **Try barcode scanning** - Use camera to scan product barcodes
5. **Read documentation:**
   - [MOBILE_APP.md](MOBILE_APP.md) - Flutter app details
   - [BACKEND.md](BACKEND.md) - API documentation
   - [README.md](README.md) - Project overview

## 📞 Support

If you encounter issues:

1. **Check logs:**
   - Backend: `backend/logs/error.log`
   - Flutter: `flutter logs`

2. **Common errors:**
   - Connection refused → Backend not running
   - Port in use → Kill process or change port
   - MySQL error → Check credentials in `.env`
   - Camera error → Grant permissions

3. **Still stuck?**
   - Check GitHub Issues
   - Review troubleshooting section above
   - Verify all prerequisites are installed

## 🔒 Security Reminder

**Before committing code:**

✅ **Never commit these files:**

- `backend/.env` (contains password)
- `flutter_app/lib/core/constants/api_constants.dart` (contains IP)

✅ **Always commit these files:**

- `backend/.env.example` (safe template)
- `flutter_app/lib/core/constants/api_constants.dart.example` (safe template)

These are already protected by `.gitignore`.

---

**Setup complete!** Start building your inventory system! 🚀
