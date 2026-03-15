#!/bin/bash

# Inventory Management System - One-Command Setup
# This script consolidates all setup steps

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  Inventory Management System - Complete Setup           ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "This script will guide you through the setup process."
echo ""

# Step 1: Prompt for MySQL password
echo -e "${YELLOW}Step 1: MySQL Password${NC}"
echo "Enter your MySQL root password (will be hidden):"
read -s MYSQL_PASSWORD
echo ""

# Step 2: Create database
echo -e "${YELLOW}Step 2: Creating Database...${NC}"
mysql -u root -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS inventory_db;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database created successfully${NC}"
else
    echo "✗ Failed to create database. Please check your password."
    echo ""
    echo "Try this manually:"
    echo "  mysql -u root -p"
    echo "  Then run: CREATE DATABASE inventory_db;"
    exit 1
fi

# Step 3: Update .env
echo ""
echo -e "${YELLOW}Step 3: Updating Configuration...${NC}"
cd ~/inventory_project/backend
sed -i.bak "s|DB_PASSWORD=.*|DB_PASSWORD=$MYSQL_PASSWORD|" .env
echo -e "${GREEN}✓ Configuration updated${NC}"

# Step 4: Test connection
echo ""
echo -e "${YELLOW}Step 4: Testing Connection...${NC}"
echo ""

# Run test with environment variables
DB_PASSWORD="$MYSQL_PASSWORD" node test_connection.js

if [ $? -eq 0 ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║             🎉 SETUP SUCCESSFUL! 🎉                      ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1️⃣  Start Backend (keep this terminal running):"
    echo "   cd ~/inventory_project/backend && npm start"
    echo ""
    echo "2️⃣  Run Flutter App (open new terminal):"
    echo "   cd ~/inventory_project/flutter_app && flutter run"
    echo ""
else
    echo ""
    echo "✗ Connection test failed"
    echo "Please verify your MySQL password and try again."
fi
