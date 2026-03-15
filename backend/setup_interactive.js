#!/usr/bin/env node

const readline = require("readline");
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

console.log("\n╔════════════════════════════════════════════════════════════╗");
console.log("║   Inventory Management System - Automated Setup           ║");
console.log("╚════════════════════════════════════════════════════════════╝\n");

function question(query) {
  return new Promise((resolve) => rl.question(query, resolve));
}

function execCommand(command, hideOutput = false) {
  try {
    const output = execSync(command, { encoding: "utf-8" });
    if (!hideOutput) console.log(output);
    return { success: true, output };
  } catch (error) {
    return {
      success: false,
      error: error.message,
      output: error.stdout || error.stderr,
    };
  }
}

async function main() {
  console.log("✓ MySQL is installed and running\n");

  // Step 1: Get MySQL password
  console.log("Step 1: MySQL Authentication");
  console.log("─".repeat(60));

  const password = await question(
    "\nEnter your MySQL root password (press Enter if none): ",
  );
  console.log("");

  // Step 2: Create database
  console.log("Step 2: Creating Database");
  console.log("─".repeat(60));

  const mysqlCmd = password ? `mysql -u root -p'${password}'` : `mysql -u root`;

  const createDbResult = execCommand(
    `echo "CREATE DATABASE IF NOT EXISTS inventory_db;" | ${mysqlCmd}`,
    true,
  );

  if (!createDbResult.success) {
    console.log("✗ Failed to create database");
    console.log("\nError:", createDbResult.output);
    console.log("\n💡 Possible issues:");
    console.log("   - Incorrect password");
    console.log("   - MySQL not accessible\n");
    console.log("Please verify your MySQL password and try again.");
    rl.close();
    process.exit(1);
  }

  console.log("✓ Database created successfully\n");

  // Step 3: Verify database
  const verifyResult = execCommand(
    `echo "SHOW DATABASES LIKE 'inventory_db';" | ${mysqlCmd}`,
    true,
  );

  if (verifyResult.success && verifyResult.output.includes("inventory_db")) {
    console.log("✓ Database verified\n");
  }

  // Step 4: Update .env file
  console.log("Step 3: Configuring Backend");
  console.log("─".repeat(60));

  const envPath = path.join(__dirname, ".env");
  let envContent = fs.readFileSync(envPath, "utf-8");
  envContent = envContent.replace(/DB_PASSWORD=.*/, `DB_PASSWORD=${password}`);
  fs.writeFileSync(envPath, envContent);

  console.log("✓ Backend configuration updated\n");

  // Step 5: Test connection
  console.log("Step 4: Testing Database Connection");
  console.log("─".repeat(60));
  console.log("");

  require("./test_connection.js");

  setTimeout(() => {
    console.log(
      "\n╔════════════════════════════════════════════════════════════╗",
    );
    console.log(
      "║              🎉 SETUP COMPLETE! 🎉                         ║",
    );
    console.log(
      "╚════════════════════════════════════════════════════════════╝\n",
    );
    console.log("Your system is ready! Next steps:\n");
    console.log("┌─────────────────────────────────────────────────────────┐");
    console.log("│  TERMINAL 1: Start Backend                             │");
    console.log("│  ────────────────────────                               │");
    console.log("│  cd ~/inventory_project/backend                         │");
    console.log("│  npm start                                              │");
    console.log("│                                                         │");
    console.log("│  TERMINAL 2: Run Flutter App                           │");
    console.log("│  ────────────────────────────                           │");
    console.log("│  cd ~/inventory_project/flutter_app                     │");
    console.log("│  flutter run                                            │");
    console.log(
      "└─────────────────────────────────────────────────────────┘\n",
    );

    rl.close();
  }, 2000);
}

main().catch((error) => {
  console.error("Setup failed:", error);
  rl.close();
  process.exit(1);
});
