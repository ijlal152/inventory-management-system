const express = require("express");
const productRoutes = require("./product.routes");
const syncRoutes = require("./sync.routes");
const authRoutes = require("./auth.routes");

const router = express.Router();

// Public routes (no authentication required)
router.use("/auth", authRoutes);

// Protected routes (authentication required)
router.use("/products", productRoutes);
router.use("/products", syncRoutes);

module.exports = router;
