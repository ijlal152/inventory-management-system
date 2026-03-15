# 🖥️ Backend Documentation

Node.js REST API with MySQL database for inventory management.

## 🎯 Overview

The backend is a RESTful API built with **Express.js** and **MySQL**, using **Sequelize ORM** for database operations. It provides endpoints for product CRUD operations and bulk synchronization.

## 🏗️ Architecture

### Project Structure

```
backend/
├── src/
│   ├── config/           # Configuration files
│   │   └── database.js   # Sequelize configuration
│   ├── models/           # Sequelize models
│   │   ├── index.js      # Model initialization
│   │   └── product.js    # Product model
│   ├── routes/           # API routes
│   │   ├── index.js      # Route registration
│   │   └── products.js   # Product endpoints
│   ├── controllers/      # Business logic
│   │   └── productController.js
│   ├── middleware/       # Express middleware
│   │   ├── errorHandler.js
│   │   └── validator.js
│   └── utils/            # Utilities
│       └── logger.js     # Winston logger
├── logs/                 # Application logs
├── .env                  # Environment variables (ignored by git)
├── .env.example          # Example environment file
└── server.js             # Entry point
```

### Technology Stack

**Framework & Tools:**

- **Express.js** (4.18.2) - Web framework
- **Sequelize** (6.35.2) - ORM for MySQL
- **MySQL2** (3.9.1) - MySQL driver
- **Winston** (3.11.0) - Logging
- **Express-Validator** (7.0.1) - Input validation
- **CORS** - Cross-origin support
- **dotenv** - Environment variables

## 📊 Database

### MySQL Configuration

**Connection Details:**

- Host: `localhost` (or `127.0.0.1`)
- Port: `3306` (default MySQL port)
- Database: `inventory_db`
- User: `root`
- Password: Set in `.env` file

### Database Schema

**Products Table:**

```sql
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  barcode VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  images JSON DEFAULT NULL,
  createdAt DATETIME NOT NULL,
  updatedAt DATETIME NOT NULL,
  INDEX idx_barcode (barcode),
  INDEX idx_name (name)
);
```

**Sequelize Model Definition:**

```javascript
const Product = sequelize.define("Product", {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  barcode: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      notEmpty: true,
    },
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: true,
    },
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: 0,
    },
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    defaultValue: 0.0,
    validate: {
      min: 0,
    },
  },
  images: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: [],
  },
});
```

### Automatic Database Setup

The database and tables are created automatically on first run:

```javascript
// In server.js
sequelize
  .sync({ alter: false })
  .then(() => console.log("Database synced"))
  .catch((err) => console.error("Database sync error:", err));
```

**Options:**

- `sync()` - Create tables if they don't exist
- `sync({ force: true })` - Drop and recreate tables (DANGER!)
- `sync({ alter: true })` - Modify existing tables to match model

## 🛣️ API Endpoints

### Base URL

```
http://localhost:3000/api
```

### Health Check

**GET** `/health`

Check if server is running.

**Response:**

```json
{
  "status": "ok",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "uptime": 3600
}
```

### Product Endpoints

#### 1. Get All Products

**GET** `/api/products`

Retrieve all products from database.

**Response:**

```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "barcode": "1234567890",
      "name": "Product A",
      "quantity": 10,
      "price": "99.99",
      "images": ["base64..."],
      "createdAt": "2024-01-01T10:00:00.000Z",
      "updatedAt": "2024-01-01T10:00:00.000Z"
    },
    {
      "id": 2,
      "barcode": "0987654321",
      "name": "Product B",
      "quantity": 5,
      "price": "49.99",
      "images": [],
      "createdAt": "2024-01-01T11:00:00.000Z",
      "updatedAt": "2024-01-01T11:00:00.000Z"
    }
  ]
}
```

#### 2. Get Product by ID

**GET** `/api/products/:id`

Retrieve a specific product.

**Parameters:**

- `id` (path) - Product ID

**Response:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "barcode": "1234567890",
    "name": "Product A",
    "quantity": 10,
    "price": "99.99",
    "images": [],
    "createdAt": "2024-01-01T10:00:00.000Z",
    "updatedAt": "2024-01-01T10:00:00.000Z"
  }
}
```

**Error Response (404):**

```json
{
  "success": false,
  "message": "Product not found"
}
```

#### 3. Create Product

**POST** `/api/products`

Create a new product.

**Request Body:**

```json
{
  "barcode": "1234567890",
  "name": "New Product",
  "quantity": 10,
  "price": 99.99,
  "images": ["base64_encoded_image_string"]
}
```

**Validation Rules:**

- `barcode`: Required, string, must be unique
- `name`: Required, string, not empty
- `quantity`: Required, integer, >= 0
- `price`: Required, number, >= 0
- `images`: Optional, array of strings

**Success Response (201):**

```json
{
  "success": true,
  "message": "Product created successfully",
  "data": {
    "id": 3,
    "barcode": "1234567890",
    "name": "New Product",
    "quantity": 10,
    "price": "99.99",
    "images": ["base64..."],
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

**Error Response (400 - Duplicate Barcode):**

```json
{
  "success": false,
  "message": "Product with this barcode already exists"
}
```

#### 4. Update Product

**PUT** `/api/products/:id`

Update an existing product.

**Parameters:**

- `id` (path) - Product ID

**Request Body:**

```json
{
  "barcode": "1234567890",
  "name": "Updated Product",
  "quantity": 15,
  "price": 89.99,
  "images": []
}
```

**Success Response:**

```json
{
  "success": true,
  "message": "Product updated successfully",
  "data": {
    "id": 1,
    "barcode": "1234567890",
    "name": "Updated Product",
    "quantity": 15,
    "price": "89.99",
    "images": [],
    "createdAt": "2024-01-01T10:00:00.000Z",
    "updatedAt": "2024-01-01T13:00:00.000Z"
  }
}
```

#### 5. Delete Product

**DELETE** `/api/products/:id`

Delete a product.

**Parameters:**

- `id` (path) - Product ID

**Success Response:**

```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

**Error Response (404):**

```json
{
  "success": false,
  "message": "Product not found"
}
```

#### 6. Bulk Sync

**POST** `/api/products/sync`

Synchronize multiple products from mobile app.

**Request Body:**

```json
{
  "products": [
    {
      "barcode": "1111111111",
      "name": "Synced Product 1",
      "quantity": 5,
      "price": 29.99,
      "images": []
    },
    {
      "barcode": "2222222222",
      "name": "Synced Product 2",
      "quantity": 8,
      "price": 39.99,
      "images": []
    }
  ]
}
```

**Success Response:**

```json
{
  "success": true,
  "message": "Sync completed",
  "synced": 2,
  "failed": 0,
  "results": [
    {
      "barcode": "1111111111",
      "success": true,
      "serverId": 10
    },
    {
      "barcode": "2222222222",
      "success": true,
      "serverId": 11
    }
  ]
}
```

**Partial Success (some failed):**

```json
{
  "success": true,
  "message": "Sync completed with some errors",
  "synced": 1,
  "failed": 1,
  "results": [
    {
      "barcode": "1111111111",
      "success": true,
      "serverId": 10
    },
    {
      "barcode": "2222222222",
      "success": false,
      "error": "Duplicate barcode"
    }
  ]
}
```

## 🔧 Configuration

### Environment Variables

Create `.env` file in `backend/` directory:

```env
# Server
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=3306
DB_NAME=inventory_db
DB_USER=root
DB_PASSWORD=your_mysql_password

# Logging
LOG_LEVEL=info
```

**Important:** Never commit `.env` file to Git! Use `.env.example` as template.

### Sequelize Configuration

Located in `src/config/database.js`:

```javascript
module.exports = {
  development: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: "mysql",
    logging: false, // Set to console.log to see SQL queries
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  },
};
```

## 📝 Logging

### Winston Logger

Logs are written to:

- **Console** - All levels in development
- **logs/error.log** - Error level only
- **logs/combined.log** - All levels

**Log Levels:**

- `error` - Error messages
- `warn` - Warning messages
- `info` - Informational messages
- `debug` - Debug messages

**Usage:**

```javascript
const logger = require("./utils/logger");

logger.info("Server started");
logger.error("Database connection failed", { error: err });
logger.debug("Product created", { product });
```

**Log Format:**

```
2024-01-01 12:00:00 [INFO]: Server started on port 3000
2024-01-01 12:01:00 [ERROR]: Database error: Connection refused
```

## 🛡️ Error Handling

### Global Error Handler

Catches all errors and returns consistent JSON response:

```javascript
{
  "success": false,
  "message": "Error message here",
  "error": "Detailed error (only in development)"
}
```

### Validation Errors

Express-validator automatically validates input:

```javascript
const { body, validationResult } = require("express-validator");

router.post(
  "/products",
  body("barcode").notEmpty().isString(),
  body("name").notEmpty().isString(),
  body("quantity").isInt({ min: 0 }),
  body("price").isFloat({ min: 0 }),
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }
    // Process request
  },
);
```

### Database Errors

Handled with try-catch and Sequelize error types:

```javascript
try {
  const product = await Product.create(data);
} catch (error) {
  if (error.name === "SequelizeUniqueConstraintError") {
    return res.status(400).json({
      success: false,
      message: "Product with this barcode already exists",
    });
  }
  throw error; // Pass to global error handler
}
```

## 🚀 Running the Server

### Development Mode

```bash
cd backend
npm install
npm start
```

Server runs on `http://0.0.0.0:3000`

### Production Mode

```bash
cd backend
npm install --production
NODE_ENV=production npm start
```

### With PM2 (Process Manager)

```bash
# Install PM2 globally
npm install -g pm2

# Start server
pm2 start server.js --name inventory-api

# View logs
pm2 logs inventory-api

# Restart
pm2 restart inventory-api

# Stop
pm2 stop inventory-api

# Auto-start on system boot
pm2 startup
pm2 save
```

## 🧪 Testing

### Manual API Testing

**With cURL:**

```bash
# Get all products
curl http://localhost:3000/api/products

# Create product
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "barcode": "1234567890",
    "name": "Test Product",
    "quantity": 10,
    "price": 99.99
  }'

# Update product
curl -X PUT http://localhost:3000/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Product",
    "quantity": 15
  }'

# Delete product
curl -X DELETE http://localhost:3000/api/products/1
```

**With Postman:**

1. Import collection from `docs/postman_collection.json`
2. Set base URL to `http://localhost:3000`
3. Test all endpoints

### Automated Tests

```bash
# Install test dependencies
npm install --save-dev mocha chai supertest

# Run tests
npm test

# With coverage
npm run test:coverage
```

## 🔐 Security Considerations

### Current Implementation

- ✅ Input validation (express-validator)
- ✅ CORS enabled
- ✅ Error handling
- ✅ Unique constraints
- ❌ No authentication
- ❌ No rate limiting
- ❌ No HTTPS

### For Production

**Add Authentication:**

```javascript
const jwt = require("jsonwebtoken");

// Middleware
const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ message: "Unauthorized" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: "Invalid token" });
  }
};

// Apply to routes
router.use("/products", authenticate);
```

**Add Rate Limiting:**

```javascript
const rateLimit = require("express-rate-limit");

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});

app.use("/api/", limiter);
```

**Use HTTPS:**

```javascript
const https = require("https");
const fs = require("fs");

const options = {
  key: fs.readFileSync("key.pem"),
  cert: fs.readFileSync("cert.pem"),
};

https.createServer(options, app).listen(443);
```

## 📊 Performance Optimization

### Database Indexing

Already configured on:

- `barcode` (unique index)
- `name` (regular index)

### Connection Pooling

Sequelize pool configuration:

```javascript
pool: {
  max: 5,        // Maximum connections
  min: 0,        // Minimum connections
  acquire: 30000, // Max time to get connection
  idle: 10000    // Max idle time before release
}
```

### Caching (Future)

Add Redis for caching:

```javascript
const redis = require("redis");
const client = redis.createClient();

// Cache GET requests
app.get("/api/products", async (req, res) => {
  const cached = await client.get("products");
  if (cached) {
    return res.json(JSON.parse(cached));
  }

  const products = await Product.findAll();
  await client.setex("products", 300, JSON.stringify(products)); // 5 min cache
  res.json(products);
});
```

## 🐛 Troubleshooting

### Server Won't Start

**Check:**

1. Port 3000 not in use: `lsof -i :3000`
2. MySQL is running: `mysql --version`
3. Environment variables set in `.env`
4. Dependencies installed: `npm install`

### Database Connection Failed

```bash
# Test MySQL connection
mysql -u root -p -h localhost

# Check MySQL is running
brew services list | grep mysql    # macOS
sudo systemctl status mysql        # Linux

# Verify credentials in .env
cat .env | grep DB_
```

### "Table doesn't exist" Error

```bash
# Sync database (creates tables)
node -e "require('./src/models').sequelize.sync()"
```

### CORS Errors

Update CORS configuration in `server.js`:

```javascript
app.use(
  cors({
    origin: ["http://localhost:3000", "http://192.168.1.100:3000"],
    credentials: true,
  }),
);
```

## 📦 Deployment

### Deploy to Ubuntu Server

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MySQL
sudo apt install mysql-server
sudo mysql_secure_installation

# Clone repo and setup
cd /var/www
git clone <your-repo>
cd backend
npm install --production

# Configure environment
cp .env.example .env
nano .env  # Edit with production values

# Run with PM2
sudo npm install -g pm2
pm2 start server.js
pm2 startup
pm2 save

# Setup firewall
sudo ufw allow 3000/tcp
```

### Docker Deployment

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

```bash
# Build and run
docker build -t inventory-api .
docker run -p 3000:3000 --env-file .env inventory-api
```

## 🎯 Future Enhancements

- [ ] GraphQL API
- [ ] Real-time updates (Socket.io)
- [ ] File upload for images
- [ ] Pagination for large datasets
- [ ] Advanced search/filtering
- [ ] Audit logs (who changed what)
- [ ] Multi-tenancy support
- [ ] Data export (CSV, Excel)
- [ ] Scheduled tasks (cron jobs)
- [ ] Email notifications

---

For mobile app details, see [MOBILE_APP.md](MOBILE_APP.md)  
For setup instructions, see [SETUP.md](SETUP.md)
