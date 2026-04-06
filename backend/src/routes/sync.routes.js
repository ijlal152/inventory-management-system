const express = require("express");
const syncController = require("../controllers/sync.controller");
const authMiddleware = require("../middleware/auth.middleware");

const router = express.Router();

// Sync routes require authentication
router.post("/sync", authMiddleware, syncController.bulkSync);

module.exports = router;
