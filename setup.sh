#!/bin/bash

clear
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Inventory Management System - Interactive Setup         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Check MySQL
echo -e "${BLUE}[1/4] Checking MySQL...${NC}"
if ps aux | grep -v grep | grep mysqld > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MySQL is running${NC}"
else
    echo -e "${RED}❌ MySQL is not running${NC}"
    echo ""
    echo "Please start MySQL first:"
    echo "  • Open System Preferences > MySQL > Start Server"
    echo "  OR"
    echo "  • Run: sudo /usr/local/mysql/support-files/mysql.server start"
    exit 1
fi
echo ""

# Step 2: Create Database
echo -e "${BLUE}[2/4] Setting up MySQL Database...${NC}"
echo ""
echo "I'll help you create the 'inventory_db' database."
echo "Please enter your MySQL root password when prompted."
echo ""
read -p "Press Enter to continue..."

mysql -u root -p << 'MYSQL_SCRIPT'
CREATE DATABASE IF NOT EXISTS inventory_db;
SHOW DATABASES LIKE 'inventory_db';
SELECT 'Database created successfully!' as Status;
MYSQL_SCRIPT

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Database setup complete!${NC}"
else
    echo ""
    echo -e "${RED}❌ Database creation failed${NC}"
    echo ""
    echo "Please try manually:"
    echo "  mysql -u root -p"
    echo "  Then run: CREATE DATABASE inventory_db;"
    exit 1
fi
echo ""

# Step 3: Configure .env
echo -e "${BLUE}[3/4] Configuring Backend...${NC}"
echo ""
echo "Now we need to save your MySQL password in the backend configuration."
echo ""
read -s -p "Enter your MySQL root password (input hidden): " DB_PASS
echo ""
echo ""

# Update .env file
cd ~/inventory_project/backend
sed -i.bak "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env

echo -e "${GREEN}✅ Configuration updated${NC}"
echo ""

# Step 4: Test Connection
echo -e "${BLUE}[4/4] Testing Database Connection...${NC}"
echo ""

node test_connection.js

if [ $? -eq 0 ]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              🎉 SETUP COMPLETE! 🎉                         ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Your system is ready! Here's what to do next:"
    echo ""
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│  1. START BACKEND (Terminal 1)                         │"
    echo "│     cd ~/inventory_project/backend                      │"
    echo "│     npm start                                           │"
    echo "│                                                         │"
    echo "│  2. RUN FLUTTER APP (Terminal 2)                       │"
    echo "│     cd ~/inventory_project/flutter_app                  │"
    echo "│     flutter run                                         │"
    echo "└─────────────────────────────────────────────────────────┘"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Connection test failed${NC}"
    echo ""
    echo "Please check your MySQL password and try again."
    echo "To retry, run: ~/inventory_project/setup.sh"
fi
