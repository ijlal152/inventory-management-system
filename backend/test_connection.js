// Test MySQL connection
require("dotenv").config();
const { Sequelize } = require("sequelize");

console.log("\n🔍 Testing MySQL Connection...\n");
console.log("Configuration:");
console.log(`  Host: ${process.env.DB_HOST}`);
console.log(`  Port: ${process.env.DB_PORT}`);
console.log(`  Database: ${process.env.DB_NAME}`);
console.log(`  User: ${process.env.DB_USER}`);
console.log(
  `  Password: ${process.env.DB_PASSWORD ? "***" + process.env.DB_PASSWORD.slice(-2) : "(empty)"}`,
);
console.log("");

const sequelize = new Sequelize(
  process.env.DB_NAME || "inventory_db",
  process.env.DB_USER || "root",
  process.env.DB_PASSWORD || "",
  {
    host: process.env.DB_HOST || "localhost",
    port: process.env.DB_PORT || 3306,
    dialect: "mysql",
    logging: false,
  },
);

(async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ MySQL Connection Successful!");
    console.log("");

    // Try to list databases
    const [databases] = await sequelize.query("SHOW DATABASES");
    console.log("📊 Available Databases:");
    databases.forEach((db) => {
      const dbName = db.Database || db.SCHEMA_NAME;
      if (dbName === "inventory_db") {
        console.log(`  ✓ ${dbName} (project database)`);
      } else {
        console.log(`    ${dbName}`);
      }
    });

    console.log("");
    console.log("🎉 Database setup is correct!");
    console.log("");
    console.log("Next step: Start the backend server");
    console.log("  cd ~/inventory_project/backend");
    console.log("  npm start");
    console.log("");

    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.log("❌ Connection Failed!");
    console.log("");
    console.log("Error:", error.message);
    console.log("");

    if (error.message.includes("Access denied")) {
      console.log("💡 Fix: Update your MySQL password in .env file");
      console.log("");
      console.log("Steps:");
      console.log("  1. Open: ~/inventory_project/backend/.env");
      console.log("  2. Update line: DB_PASSWORD=your_actual_password");
      console.log("  3. Save and run this script again");
      console.log("");
    } else if (error.message.includes("Unknown database")) {
      console.log("💡 Fix: Create the database");
      console.log("");
      console.log("Run this command:");
      console.log('  mysql -u root -p -e "CREATE DATABASE inventory_db;"');
      console.log("");
    }

    await sequelize.close();
    process.exit(1);
  }
})();
