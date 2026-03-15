#!/bin/bash

echo "============================================"
echo "  MySQL Database Setup for Inventory App"
echo "============================================"
echo ""
echo "This script will:"
echo "1. Create the 'inventory_db' database"
echo "2. Verify the database was created"
echo ""
echo "Please enter your MySQL root password when prompted."
echo ""

# Create database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS inventory_db;"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database 'inventory_db' created successfully!"
    echo ""
    echo "Verifying database exists..."
    mysql -u root -p -e "SHOW DATABASES;" | grep inventory_db
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Database verified!"
        echo ""
        echo "📝 Next step: Update the .env file with your MySQL password"
        echo ""
        echo "Run: nano backend/.env"
        echo "Then update the DB_PASSWORD line"
        echo ""
    fi
else
    echo ""
    echo "❌ Failed to create database"
    echo ""
    echo "Troubleshooting tips:"
    echo "- Make sure you entered the correct MySQL root password"
    echo "- If you don't know the password, you may need to reset it"
    echo ""
fi
