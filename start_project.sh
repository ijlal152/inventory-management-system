#!/bin/bash

echo ""
echo "🚀 Starting Inventory Management System"
echo "========================================"
echo ""

# Check if MySQL is running
if ! ps aux | grep -v grep | grep mysqld > /dev/null; then
    echo "❌ MySQL is not running!"
    echo ""
    echo "To start MySQL:"
    echo "  Option 1: System Preferences > MySQL > Start"
    echo "  Option 2: sudo /usr/local/mysql/support-files/mysql.server start"
    echo ""
    exit 1
fi

echo "✅ MySQL is running"
echo ""

# Check if database exists
echo "Checking if database exists..."
if mysql -u root -p -e "USE inventory_db;" 2>/dev/null; then
    echo "✅ Database 'inventory_db' already exists"
else
    echo "⚠️  Database 'inventory_db' does not exist"
    echo ""
    echo "Creating database..."
    mysql -u root -p -e "CREATE DATABASE inventory_db;"
    
    if [ $? -eq 0 ]; then
        echo "✅ Database created successfully!"
    else
        echo "❌ Failed to create database"
        echo "Please run: mysql -u root -p"
        echo "Then execute: CREATE DATABASE inventory_db;"
        exit 1
    fi
fi

echo ""
echo "✅ Database setup complete!"
echo ""
echo "📝 IMPORTANT: Update your .env file with MySQL password"
echo "   File: ~/inventory_project/backend/.env"
echo "   Set: DB_PASSWORD=your_mysql_password"
echo ""
echo "Then run:"
echo "   cd ~/inventory_project/backend && npm start"
echo ""
