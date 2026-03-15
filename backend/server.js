require("dotenv").config();
const app = require("./src/app");
const { connectDB } = require("./src/config/database");
const logger = require("./src/utils/logger");

const PORT = process.env.PORT || 3000;

// Connect to database
connectDB().then(() => {
  // Start server - listen on all network interfaces for emulator access
  app.listen(PORT, "0.0.0.0", () => {
    logger.info(`Server running on port ${PORT}`);
    logger.info(`Environment: ${process.env.NODE_ENV}`);
    logger.info(`API available at: http://localhost:${PORT}/api`);
    logger.info(`Emulator access: http://10.0.2.2:${PORT}/api`);
  });
});
