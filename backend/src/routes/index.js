const express = require("express");
const productRoutes = require("./product.routes");
const syncRoutes = require("./sync.routes");

const router = express.Router();

router.use("/products", productRoutes);
router.use("/products", syncRoutes);

module.exports = router;
