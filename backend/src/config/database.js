const { Sequelize } = require("sequelize");
const logger = require("../utils/logger");

const sequelize = new Sequelize(
  process.env.DB_NAME || "inventory_db",
  process.env.DB_USER || "root",
  process.env.DB_PASSWORD || "",
  {
    host: process.env.DB_HOST || "localhost",
    port: process.env.DB_PORT || 3306,
    dialect: "mysql",
    logging: (msg) => logger.debug(msg),
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  },
);

const connectDB = async () => {
  try {
    await sequelize.authenticate();
    logger.info("MySQL Database Connected Successfully");

    // Sync models with database (creates tables if they don't exist)
    // Use force: true to drop and recreate tables (CAUTION: deletes all data)
    // Use alter: true to update existing tables without dropping them
    await sequelize.sync({ alter: true });
    logger.info("Database synchronized");
  } catch (error) {
    logger.error(`Database Connection Error: ${error.message}`);
    process.exit(1);
  }
};

module.exports = { sequelize, connectDB };
